defmodule Blog.Admin.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :position, :integer, default: 0
    
    belongs_to :parent, Blog.Admin.Category
    has_many :children, Blog.Admin.Category, foreign_key: :parent_id
    has_many :posts, Blog.Post
    has_many :drafts, Blog.Admin.Draft

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug, :description, :parent_id, :position])
    |> validate_required([:name, :slug])
    |> validate_length(:name, min: 1, max: 100)
    |> unique_constraint(:slug)
    |> generate_slug()
    |> validate_no_self_parent()
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
  
  defp validate_no_self_parent(changeset) do
    case get_field(changeset, :id) do
      nil -> changeset
      id ->
        validate_change(changeset, :parent_id, fn :parent_id, parent_id ->
          if parent_id == id do
            [parent_id: "cannot be self"]
          else
            []
          end
        end)
    end
  end
end