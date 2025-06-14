defmodule Blog.Admin.Series do
  use Ecto.Schema
  import Ecto.Changeset
  
  schema "series" do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :cover_image, :string
    field :is_complete, :boolean, default: false
    
    belongs_to :user, Blog.Accounts.Users
    has_many :posts, Blog.Post
    has_many :drafts, Blog.Admin.Draft

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(series, attrs) do
    series
    |> cast(attrs, [:title, :slug, :description, :cover_image, :is_complete, :user_id])
    |> validate_required([:title, :slug, :user_id])
    |> validate_length(:title, min: 1, max: 200)
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