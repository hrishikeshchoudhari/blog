defmodule Blog.Repo.Migrations.AddCategoriesAndContentFeatures do
  use Ecto.Migration

  def change do
    # Create categories table
    create table(:categories) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :parent_id, references(:categories, on_delete: :nilify_all)
      add :position, :integer, default: 0
      
      timestamps(type: :utc_datetime)
    end
    
    create unique_index(:categories, [:slug])
    create index(:categories, [:parent_id])
    
    # Create series table for post collections
    create table(:series) do
      add :title, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :cover_image, :string
      add :is_complete, :boolean, default: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      
      timestamps(type: :utc_datetime)
    end
    
    create unique_index(:series, [:slug])
    create index(:series, [:user_id])
    
    # Add category to posts and drafts
    alter table(:posts) do
      add :category_id, references(:categories, on_delete: :nilify_all)
      add :is_featured, :boolean, default: false
      add :featured_at, :utc_datetime
      add :series_id, references(:series, on_delete: :nilify_all)
      add :series_position, :integer
    end
    
    alter table(:drafts) do
      add :category_id, references(:categories, on_delete: :nilify_all)
      add :is_featured, :boolean, default: false
      add :featured_at, :utc_datetime
      add :series_id, references(:series, on_delete: :nilify_all)
      add :series_position, :integer
    end
    
    create index(:posts, [:category_id])
    create index(:posts, [:is_featured, :featured_at])
    create index(:posts, [:series_id, :series_position])
    
    create index(:drafts, [:category_id])
    create index(:drafts, [:series_id])
    
    # Create related posts join table
    create table(:related_posts, primary_key: false) do
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :related_post_id, references(:posts, on_delete: :delete_all), null: false
      add :relevance_score, :float, default: 1.0
      
      timestamps(type: :utc_datetime)
    end
    
    create index(:related_posts, [:post_id])
    create index(:related_posts, [:related_post_id])
    create unique_index(:related_posts, [:post_id, :related_post_id])
    
    # Add constraint to prevent self-relations
    create constraint(:related_posts, :no_self_relation, check: "post_id != related_post_id")
  end
end