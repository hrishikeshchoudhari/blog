defmodule Blog.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :slug, :string, null: false
      add :title, :string, null: false
      add :content, :text
      add :meta_description, :string
      add :is_published, :boolean, default: true
      add :custom_data, :map, default: %{}
      
      timestamps()
    end

    create unique_index(:pages, [:slug])
    
    # Insert default pages
    execute """
    INSERT INTO pages (slug, title, content, meta_description, inserted_at, updated_at)
    VALUES 
    ('about', 'About', '', 'Learn more about Rishi', NOW(), NOW()),
    ('stance', 'Stance', '', 'My beliefs and philosophy', NOW(), NOW()),
    ('tools', 'Tools', '', 'Tools I use and recommend', NOW(), NOW())
    """
  end
end