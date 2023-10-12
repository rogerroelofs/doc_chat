defmodule DocChat.ArticlesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DocChat.Articles` context.
  """

  @doc """
  Generate a article.
  """
  def article_fixture(attrs \\ %{}) do
    {:ok, article} =
      attrs
      |> Enum.into(%{
        content: "some content",
        title: "some title",
        url: "some url"
      })
      |> DocChat.Articles.create_article()

    article
  end
end
