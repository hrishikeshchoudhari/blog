defmodule Blog.Repo.Migrations.AddRawBodyToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :raw_body, :text
    end
  end
end
