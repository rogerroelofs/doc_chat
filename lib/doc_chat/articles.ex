defmodule DocChat.Articles do
  @moduledoc """
  The Articles context.
  """

  import Ecto.Query, warn: false
  alias DocChat.Repo

  alias DocChat.Articles.Article

  alias LangChain.Function
  alias LangChain.Message
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOpenAI

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles do
    Repo.all(Article)
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123)
      %Article{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article!(id), do: Repo.get!(Article, id)

  @doc """
  Creates a article.

  ## Examples

      iex> create_article(%{field: value})
      {:ok, %Article{}}

      iex> create_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article(attrs \\ %{}) do
    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a article.

  ## Examples

      iex> update_article(article, %{field: new_value})
      {:ok, %Article{}}

      iex> update_article(article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article changes.

  ## Examples

      iex> change_article(article)
      %Ecto.Changeset{data: %Article{}}

  """
  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end

  @spec search(String.t()) :: list(%Article{})
  @doc """
  Returns the list of articles matching search term.

  ## Examples

      iex> search("hello")
      [%Article{}, ...]

  """
  def search(search_term) do
    query =
      from(a in Article,
        where:
          fragment(
            "searchable @@ websearch_to_tsquery(?)",
            ^search_term
          ),
        order_by: {
          :desc,
          fragment(
            "ts_rank_cd(searchable, websearch_to_tsquery(?), 4)",
            ^search_term
          )
        }
      )

    Repo.all(query)
  end

  @spec import(String.t()) :: list(%Article{})
  @doc """
  imports all the json files in the specified directory

  ## Examples

      iex> import("path/to/files")
      [%Article{}, ...]

  """
  def import(path) do
    location = Path.expand(path)
    Path.wildcard("#{location}/*.json")
    |> Enum.map(fn file ->
      File.read!(file)
      |> Jason.decode!()
      |> create_article()
    end)
  end

  @spec ask(String.t()) :: String.t()
  @doc """
  Sends the query to ChatGPT and returns the result.

  ## Examples

      iex> ask("hello")
      "Some Text"

  """
  def ask(question) do
    system_msg = "As an Apricot customer support tech use get_apricot_instructions to answer questions"
    # a custom Elixir function made available to the LLM
    custom_fn =
      Function.new!(%{
        name: "get_apricot_instructions",
        description: "returns a list of instructions for how to use Apricot.",
        parameters_schema: %{
          type: "object",
          properties: %{
            subject: %{
              type: "string",
              description: "The subject of the help request."
            }
          },
          required: ["subject"]
        },
        function: fn %{"subject" => subject} = _args, _context ->
          content = search(subject)
            |> Enum.filter(fn article ->
              ! String.contains?(article.content, ["egistration", "Funders", "not support"])
            end)
            |> Enum.take(3)
            |> Enum.map(fn article ->
              %{
                content: String.slice(article.content, 0..400),
                url: article.url
              }
            end)
          Jason.encode!(content)
        end
      })

    # create and run the chain
    {:ok, _updated_chain, %Message{} = message} =
      LLMChain.new!(%{
        llm: ChatOpenAI.new!(%{model: "gpt-3.5-turbo-0613", temperature: 1, stream: false}),
        # verbose: true
      })
      |> LLMChain.add_functions([custom_fn])
      |> LLMChain.add_message(Message.new_system!(system_msg))
      |> LLMChain.add_message(Message.new_user!(question))
      |> LLMChain.run(while_needs_response: true)

    message.content
  end
end
