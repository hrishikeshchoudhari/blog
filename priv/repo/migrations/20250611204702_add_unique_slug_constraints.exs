defmodule Blog.Repo.Migrations.AddUniqueSlugConstraints do
  use Ecto.Migration

  def change do
    # Add unique index to drafts slug
    create unique_index(:drafts, [:slug])
    
    # Add unique index to posts slug
    create unique_index(:posts, [:slug])
  end
end