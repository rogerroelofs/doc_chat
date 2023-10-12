defmodule DocChat.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def up do
    create table(:articles) do
      add :title, :string
      add :url, :string
      add :content, :text

      timestamps()
    end

    execute """
      ALTER TABLE articles
        ADD COLUMN searchable tsvector
        GENERATED ALWAYS AS (
          setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
          setweight(to_tsvector('english', coalesce(content, '')), 'B')
        ) STORED;
    """

    execute """
      CREATE INDEX articles_searchable_idx ON articles USING gin(searchable);
    """
  end

  def down do
    drop table(:articles)
  end
end
