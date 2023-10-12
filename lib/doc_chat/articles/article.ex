defmodule DocChat.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:title, :content, :url]}

  schema "articles" do
    field :content, :string
    field :title, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :url, :content])
    |> validate_required([:title, :url, :content])
  end
end
