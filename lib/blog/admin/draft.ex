defmodule Blog.Admin.Draft do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Admin.{Tag, Category, Series}

  schema "drafts" do
    field :title, :string
    field :body, :string
    field :raw_body, :string
    field :slug, :string
    field :publishedDate, :utc_datetime
    field :post_type, :string, default: "post"
    
    # SEO fields
    field :meta_description, :string
    field :meta_keywords, :string
    field :og_title, :string
    field :og_description, :string
    field :og_image, :string
    field :twitter_card_type, :string, default: "summary_large_image"
    field :canonical_url, :string
    field :seo_data, :map, default: %{}
    
    # Content organization fields
    field :is_featured, :boolean, default: false
    field :featured_at, :utc_datetime
    field :series_position, :integer
    
    # Reading-specific fields
    field :author, :string
    field :isbn, :string
    field :rating, :integer
    field :date_read, :date
    
    # Project-specific fields
    field :demo_url, :string
    field :github_url, :string
    field :tech_stack, {:array, :string}
    
    belongs_to :category, Category
    belongs_to :series, Series
    many_to_many :tags, Tag, join_through: "drafts_tags", on_replace: :delete
    has_many :revisions, Blog.Admin.DraftRevision
    
    field :revision_count, :integer, default: 0
    field :last_auto_save_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(draft, attrs) do
    # Handle tech_stack conversion if it's a string
    attrs = handle_tech_stack(attrs)
    
    draft
    |> cast(attrs, [:title, :body, :raw_body, :slug, :publishedDate, :post_type,
                    :meta_description, :meta_keywords, :og_title, :og_description,
                    :og_image, :twitter_card_type, :canonical_url, :seo_data,
                    :is_featured, :featured_at, :category_id, :series_id, :series_position,
                    :author, :isbn, :rating, :date_read,
                    :demo_url, :github_url, :tech_stack])
    |> validate_required([:title, :body, :slug, :publishedDate, :post_type])
    |> validate_length(:meta_description, max: 160)
    |> validate_length(:meta_keywords, max: 255)
    |> validate_inclusion(:twitter_card_type, ["summary", "summary_large_image", "app", "player"])
    |> validate_inclusion(:post_type, ["post", "project", "reading"])
    |> validate_rating()
    |> unique_constraint(:slug)
    |> generate_slug()
    |> maybe_set_featured_at()
  end
  
  defp handle_tech_stack(attrs) do
    case Map.get(attrs, "tech_stack") do
      nil -> attrs
      [] -> attrs
      tech_stack when is_list(tech_stack) -> attrs
      tech_stack when is_binary(tech_stack) ->
        parsed = if tech_stack == "" do
          []
        else
          String.split(tech_stack, ",") |> Enum.map(&String.trim/1)
        end
        Map.put(attrs, "tech_stack", parsed)
    end
  end
  
  defp validate_rating(changeset) do
    if get_field(changeset, :post_type) == "reading" do
      validate_inclusion(changeset, :rating, 1..5)
    else
      changeset
    end
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
  
  defp maybe_set_featured_at(changeset) do
    case get_change(changeset, :is_featured) do
      true -> put_change(changeset, :featured_at, DateTime.utc_now() |> DateTime.truncate(:second))
      false -> put_change(changeset, :featured_at, nil)
      _ -> changeset
    end
  end
end
