defmodule Blog.Repo.Migrations.CreateMediaLibrary do
  use Ecto.Migration

  def change do
    create table(:media_items) do
      add :filename, :string, null: false
      add :original_filename, :string, null: false
      add :content_type, :string, null: false
      add :size, :integer, null: false
      add :width, :integer
      add :height, :integer
      add :alt_text, :text
      add :caption, :text
      add :path, :string, null: false
      add :thumbnail_path, :string
      add :medium_path, :string
      add :user_id, references(:users, on_delete: :restrict), null: false
      
      timestamps(type: :utc_datetime)
    end

    create index(:media_items, [:user_id])
    create index(:media_items, [:inserted_at])
  end
end
