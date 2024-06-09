defmodule Blog.Repo.Migrations.SlugPubdateInPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :slug, :string
      add :publishedDate, :utc_datetime
    end
  end
end
