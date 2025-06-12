defmodule Blog.Admin.Draft do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Admin.Tag

  schema "drafts" do
    field :title, :string
    field :body, :string
    field :raw_body, :string
    field :slug, :string
    field :publishedDate, :utc_datetime

    many_to_many :tags, Tag, join_through: "drafts_tags", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(draft, attrs) do
    draft
    |> cast(attrs, [:title, :body, :raw_body, :slug, :publishedDate])
    |> validate_required([:title, :body, :slug, :publishedDate])
    |> unique_constraint(:slug)
    |> generate_slug()
  end

  defp generate_slug(changeset) do
    case get_change(changeset, :title) do
      nil -> changeset
      title ->
        slug = title
        |> String.downcase()
        |> String.replace(~r/[^a-z0-9\s-]/, "")
        |> String.replace(~r/\s+/, "-")
        |> String.trim("-")
        
        put_change(changeset, :slug, slug)
    end
  end
end
