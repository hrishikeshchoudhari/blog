defmodule Blog.Admin.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Admin.Draft
  alias Blog.Post

  schema "tags" do
    field :name, :string
    field :slug, :string
    field :description, :string

    many_to_many :drafts, Draft, join_through: "drafts_tags"
    many_to_many :posts, Post, join_through: "posts_tags"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :slug, :description])
    |> validate_required([:name, :slug, :description])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
    |> generate_slug()
  end

  defp generate_slug(changeset) do
    case get_change(changeset, :name) do
      nil -> changeset
      name ->
        slug = name
        |> String.downcase()
        |> String.replace(~r/[^a-z0-9\s-]/, "")
        |> String.replace(~r/\s+/, "-")
        |> String.trim("-")
        
        put_change(changeset, :slug, slug)
    end
  end
end
