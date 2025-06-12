defmodule Blog.Repo.Migrations.AddRawBodyToDrafts do
  use Ecto.Migration

  def change do
    alter table(:drafts) do
      add :raw_body, :text
    end
  end
end
