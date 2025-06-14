defmodule Blog.Admin.DraftRevision do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Admin.Draft
  alias Blog.Accounts.Users

  schema "draft_revisions" do
    field :title, :string
    field :body, :string
    field :raw_body, :string
    field :slug, :string
    field :publishedDate, :utc_datetime
    field :meta_description, :string
    field :meta_keywords, :string
    field :og_title, :string
    field :og_description, :string
    field :og_image, :string
    field :twitter_card_type, :string, default: "summary_large_image"
    field :canonical_url, :string
    field :seo_data, :map, default: %{}
    field :is_featured, :boolean, default: false
    field :series_position, :integer
    field :category_id, :integer
    field :series_id, :integer
    field :revision_note, :string
    field :auto_saved, :boolean, default: false
    
    belongs_to :draft, Draft
    belongs_to :user, Users

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(revision, attrs) do
    revision
    |> cast(attrs, [
      :draft_id, :user_id, :title, :body, :raw_body, :slug, :publishedDate,
      :meta_description, :meta_keywords, :og_title, :og_description, :og_image,
      :twitter_card_type, :canonical_url, :seo_data, :is_featured, :series_position,
      :category_id, :series_id, :revision_note, :auto_saved
    ])
    |> validate_required([:draft_id, :user_id])
  end
end