defmodule Blog.Repo.Migrations.AddTypeSpecificFields do
  use Ecto.Migration

  def change do
    # Add reading-specific fields to posts table
    alter table(:posts) do
      add :author, :string
      add :isbn, :string
      add :rating, :integer
      add :date_read, :date
    end

    # Add project-specific fields to posts table
    alter table(:posts) do
      add :demo_url, :string
      add :github_url, :string
      add :tech_stack, {:array, :string}
    end

    # Add reading-specific fields to drafts table
    alter table(:drafts) do
      add :author, :string
      add :isbn, :string
      add :rating, :integer
      add :date_read, :date
    end

    # Add project-specific fields to drafts table
    alter table(:drafts) do
      add :demo_url, :string
      add :github_url, :string
      add :tech_stack, {:array, :string}
    end
  end
end
