defmodule Blog.Repo.Migrations.UniqueTags do
  use Ecto.Migration

  def change do
    create index("tags", [:name], unique: true)
  end
end
