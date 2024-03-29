defmodule Blog.Admin.Draft do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drafts" do
    field :title, :string
    field :body, :string
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
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end
