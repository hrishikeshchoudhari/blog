defmodule Blog.Repo.Migrations.CreateDraftRevisions do
  use Ecto.Migration

  def change do
    create table(:draft_revisions) do
      add :draft_id, references(:drafts, on_delete: :delete_all), null: false
      add :title, :string
      add :body, :text
      add :raw_body, :text
      add :slug, :string
      add :publishedDate, :utc_datetime
      add :meta_description, :text
      add :meta_keywords, :text
      add :og_title, :string
      add :og_description, :text
      add :og_image, :string
      add :twitter_card_type, :string
      add :canonical_url, :string
      add :seo_data, :map, default: %{}
      add :is_featured, :boolean, default: false
      add :series_position, :integer
      add :category_id, :integer
      add :series_id, :integer
      add :revision_note, :string
      add :auto_saved, :boolean, default: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      
      timestamps(updated_at: false)
    end

    create index(:draft_revisions, [:draft_id])
    create index(:draft_revisions, [:inserted_at])
    
    # Add revision count to drafts
    alter table(:drafts) do
      add :revision_count, :integer, default: 0
      add :last_auto_save_at, :utc_datetime
    end
  end
end