defmodule Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Admin.Tag

  schema "posts" do
    field :title, :string
    field :body, :string
    field :raw_body, :string
    field :slug, :string
    field :publishedDate, :utc_datetime

    many_to_many :tags, Tag, join_through: "posts_tags", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :raw_body, :slug, :publishedDate])
    |> validate_required([:title, :body, :slug, :publishedDate])
    |> unique_constraint(:slug)
  end
end
