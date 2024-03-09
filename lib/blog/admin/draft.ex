defmodule Blog.Admin.Draft do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drafts" do
    field :title, :string
    field :body, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(draft, attrs) do
    draft
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end
