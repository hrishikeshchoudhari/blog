defmodule Blog.Admin do
  @moduledoc """
  The Admin context
  """
  import Ecto.Query, warn: false
  alias Blog.Admin.{Draft, Tag}
  alias Blog.Post
  alias Blog.Repo
  require Md
  require Logger

  def save_draft(draft_params) do
    tag_ids = Map.get(draft_params, "tag_ids", [])
    tag_ids = Enum.filter(tag_ids, fn id -> id != "" && id != nil end)
    
    # Store the raw markdown
    raw_body = Map.get(draft_params, "body", "")
    draft_params = Map.put(draft_params, "raw_body", raw_body)
    
    # First create the draft without tags
    draft = %Draft{}
    |> Draft.changeset(draft_params)
    |> Repo.insert!()
    
    # Then associate tags with timestamps
    if length(tag_ids) > 0 do
      now = DateTime.utc_now() |> DateTime.truncate(:second)
      tag_associations = Enum.map(tag_ids, fn tag_id ->
        %{
          draft_id: draft.id,
          tag_id: String.to_integer(to_string(tag_id)),
          inserted_at: now,
          updated_at: now
        }
      end)
      
      Repo.insert_all("drafts_tags", tag_associations)
    end
    
    draft
  end

  def publish_post(post_params) do
    tag_ids = Map.get(post_params, "tag_ids", [])
    tag_ids = Enum.filter(tag_ids, fn id -> id != "" && id != nil end)
    
    # Store the raw markdown and generate HTML
    raw_body = Map.get(post_params, "body", "")
    post_params = post_params
    |> Map.put("raw_body", raw_body)
    |> Map.update!("body", &Md.generate/1)

    # First create the post without tags
    post = %Post{}
    |> Post.changeset(post_params)
    |> Repo.insert!()
    
    # Then associate tags with timestamps
    if length(tag_ids) > 0 do
      now = DateTime.utc_now() |> DateTime.truncate(:second)
      tag_associations = Enum.map(tag_ids, fn tag_id ->
        %{
          post_id: post.id,
          tag_id: String.to_integer(to_string(tag_id)),
          inserted_at: now,
          updated_at: now
        }
      end)
      
      Repo.insert_all("posts_tags", tag_associations)
    end
    
    post
  end

  def all_drafts() do
    # %Draft{}
    # |> Repo.all()

    Repo.all(Draft)
  end

  def save_tag(tag_content) do
    %Tag{}
    |> Tag.changeset(tag_content)
    |> Repo.insert()
  end

  def all_tags() do
    Repo.all(Tag)
  end
  
  def list_tags() do
    Repo.all(Tag)
  end

  def nice_work() do
    #this is a nice way to write code
  end

  def get_draft!(id) do
    Draft
    |> Repo.get!(id)
    |> Repo.preload(:tags)
  end

  def get_post!(id) do
    Post
    |> Repo.get!(id)
    |> Repo.preload(:tags)
  end

  def update_post(%Post{} = post, attrs) do
    tag_ids = Map.get(attrs, "tag_ids", [])
    tag_ids = Enum.filter(tag_ids, fn id -> id != "" && id != nil end)
    
    # Check if we're receiving markdown (from the body field)
    attrs = if Map.has_key?(attrs, "body") do
      raw_body = Map.get(attrs, "body", "")
      attrs
      |> Map.put("raw_body", raw_body)
      |> Map.update!("body", &Md.generate/1)
    else
      attrs
    end
    
    # Update the post
    {:ok, updated_post} = post
    |> Post.changeset(attrs)
    |> Repo.update()
    
    # Clear existing tag associations
    Repo.delete_all(from t in "posts_tags", where: t.post_id == ^updated_post.id)
    
    # Add new tag associations
    if length(tag_ids) > 0 do
      now = DateTime.utc_now() |> DateTime.truncate(:second)
      tag_associations = Enum.map(tag_ids, fn tag_id ->
        %{
          post_id: updated_post.id,
          tag_id: String.to_integer(to_string(tag_id)),
          inserted_at: now,
          updated_at: now
        }
      end)
      
      Repo.insert_all("posts_tags", tag_associations)
    end
    
    {:ok, Repo.preload(updated_post, :tags, force: true)}
  end

  def update_draft(%Draft{} = draft, attrs) do
    tag_ids = Map.get(attrs, "tag_ids", [])
    tag_ids = Enum.filter(tag_ids, fn id -> id != "" && id != nil end)
    
    # Store the raw markdown
    attrs = if Map.has_key?(attrs, "body") do
      raw_body = Map.get(attrs, "body", "")
      Map.put(attrs, "raw_body", raw_body)
    else
      attrs
    end
    
    # Update the draft
    {:ok, updated_draft} = draft
    |> Draft.changeset(attrs)
    |> Repo.update()
    
    # Clear existing tag associations
    Repo.delete_all(from t in "drafts_tags", where: t.draft_id == ^updated_draft.id)
    
    # Add new tag associations
    if length(tag_ids) > 0 do
      now = DateTime.utc_now() |> DateTime.truncate(:second)
      tag_associations = Enum.map(tag_ids, fn tag_id ->
        %{
          draft_id: updated_draft.id,
          tag_id: String.to_integer(to_string(tag_id)),
          inserted_at: now,
          updated_at: now
        }
      end)
      
      Repo.insert_all("drafts_tags", tag_associations)
    end
    
    {:ok, Repo.preload(updated_draft, :tags, force: true)}
  end


end
