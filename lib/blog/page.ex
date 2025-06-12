defmodule Blog.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :slug, :string
    field :title, :string
    field :content, :string
    field :meta_description, :string
    field :is_published, :boolean, default: true
    field :custom_data, :map, default: %{}

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:slug, :title, :content, :meta_description, :is_published, :custom_data])
    |> validate_required([:slug, :title])
    |> unique_constraint(:slug)
  end
end