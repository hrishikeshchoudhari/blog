defmodule Blog.Repo.Migrations.CreateDrafts do
  use Ecto.Migration

  def change do
    create table(:drafts) do
      add :title, :string
      add :body, :text

      timestamps(type: :utc_datetime)
    end
  end
end
