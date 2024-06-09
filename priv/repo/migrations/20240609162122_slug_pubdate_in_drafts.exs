defmodule Blog.Repo.Migrations.SlugPubdateInDrafts do
  use Ecto.Migration

  def change do
    alter table(:drafts) do
      add :slug, :string
      add :publishedDate, :utc_datetime
    end
  end
end
