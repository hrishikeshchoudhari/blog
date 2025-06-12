defmodule Blog.Repo.Migrations.CreateDraftsTagsAndPostsTags do
  use Ecto.Migration

  def change do
    # Create join table for drafts and tags
    create table(:drafts_tags, primary_key: false) do
      add :draft_id, references(:drafts, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: :delete_all), null: false
      
      timestamps(type: :utc_datetime)
    end

    create unique_index(:drafts_tags, [:draft_id, :tag_id])
    create index(:drafts_tags, [:draft_id])
    create index(:drafts_tags, [:tag_id])

    # Create join table for posts and tags
    create table(:posts_tags, primary_key: false) do
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: :delete_all), null: false
      
      timestamps(type: :utc_datetime)
    end

    create unique_index(:posts_tags, [:post_id, :tag_id])
    create index(:posts_tags, [:post_id])
    create index(:posts_tags, [:tag_id])
  end
end