defmodule Blog.Admin.Draft do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drafts" do
    field :title, :string
    field :body, :string
    field :slug, :string
    field :publishedDate, :utc_datetime
    # TODO
    # unique slug field
    # change ID to UUID ?
    # should slug be used as URL ?
    # should latest boolean be created ?

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(draft, attrs) do
    draft
    |> cast(attrs, [:title, :body, :slug, :publishedDate])
    |> validate_required([:title, :body, :slug, :publishedDate])
  end
end
