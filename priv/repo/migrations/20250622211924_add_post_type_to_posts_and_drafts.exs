defmodule Blog.Repo.Migrations.AddPostTypeToPostsAndDrafts do
  use Ecto.Migration

  def change do
    # Add post_type to posts table
    alter table(:posts) do
      add :post_type, :string, default: "post", null: false
    end

    # Add post_type to drafts table
    alter table(:drafts) do
      add :post_type, :string, default: "post", null: false
    end

    # Create indexes for efficient filtering
    create index(:posts, [:post_type])
    create index(:drafts, [:post_type])
  end
end
