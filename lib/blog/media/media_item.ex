defmodule Blog.Media.MediaItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Accounts.Users

  schema "media_items" do
    field :filename, :string
    field :original_filename, :string
    field :content_type, :string
    field :size, :integer
    field :width, :integer
    field :height, :integer
    field :alt_text, :string
    field :caption, :string
    field :path, :string
    field :thumbnail_path, :string
    field :medium_path, :string
    
    belongs_to :user, Users

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(media_item, attrs) do
    media_item
    |> cast(attrs, [:filename, :original_filename, :content_type, :size, 
                    :width, :height, :alt_text, :caption, :path, 
                    :thumbnail_path, :medium_path, :user_id])
    |> validate_required([:filename, :original_filename, :content_type, 
                         :size, :path, :user_id])
    |> validate_format(:content_type, ~r/^image\/(jpeg|jpg|png|gif|webp)$/i)
  end

  @doc false
  def update_changeset(media_item, attrs) do
    media_item
    |> cast(attrs, [:alt_text, :caption])
  end
end