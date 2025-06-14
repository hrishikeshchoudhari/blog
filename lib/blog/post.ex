defmodule Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Admin.{Tag, Category, Series}

  schema "posts" do
    field :title, :string
    field :body, :string
    field :raw_body, :string
    field :slug, :string
    field :publishedDate, :utc_datetime
    
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
    
    belongs_to :category, Category
    belongs_to :series, Series
    many_to_many :tags, Tag, join_through: "posts_tags", on_replace: :delete
    
    # Related posts
    many_to_many :related_posts, Blog.Post,
      join_through: "related_posts",
      join_keys: [post_id: :id, related_post_id: :id]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :raw_body, :slug, :publishedDate,
                    :meta_description, :meta_keywords, :og_title, :og_description,
                    :og_image, :twitter_card_type, :canonical_url, :seo_data,
                    :is_featured, :featured_at, :category_id, :series_id, :series_position])
    |> validate_required([:title, :body, :slug, :publishedDate])
    |> validate_length(:meta_description, max: 160)
    |> validate_length(:meta_keywords, max: 255)
    |> validate_inclusion(:twitter_card_type, ["summary", "summary_large_image", "app", "player"])
    |> unique_constraint(:slug)
    |> maybe_set_featured_at()
  end
  
  defp maybe_set_featured_at(changeset) do
    case get_change(changeset, :is_featured) do
      true -> put_change(changeset, :featured_at, DateTime.utc_now() |> DateTime.truncate(:second))
      false -> put_change(changeset, :featured_at, nil)
      _ -> changeset
    end
  end
end
