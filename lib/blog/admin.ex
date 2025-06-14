defmodule Blog.Admin do
  @moduledoc """
  The Admin context
  """
  import Ecto.Query, warn: false
  alias Blog.Admin.{Draft, Tag, DraftRevision}
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

  # Categories
  
  alias Blog.Admin.{Category, Series}
  
  def list_categories do
    Category
    |> order_by([c], [c.position, c.name])
    |> Repo.all()
    |> Repo.preload(:parent)
  end
  
  def get_category!(id) do
    Category
    |> Repo.get!(id)
    |> Repo.preload([:parent, :children])
  end
  
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end
  
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end
  
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end
  
  # Series
  
  def list_series(user_id) do
    Series
    |> where([s], s.user_id == ^user_id)
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end
  
  def get_series!(id) do
    Series
    |> Repo.get!(id)
    |> Repo.preload(posts: from(p in Post, order_by: p.series_position))
  end
  
  def create_series(attrs \\ %{}) do
    %Series{}
    |> Series.changeset(attrs)
    |> Repo.insert()
  end
  
  def update_series(%Series{} = series, attrs) do
    series
    |> Series.changeset(attrs)
    |> Repo.update()
  end
  
  def delete_series(%Series{} = series) do
    Repo.delete(series)
  end
  
  # Featured posts
  
  def list_featured_posts(limit \\ 5) do
    Post
    |> where([p], p.is_featured == true)
    |> order_by([p], desc: p.featured_at)
    |> limit(^limit)
    |> preload(:tags)
    |> Repo.all()
  end
  
  def toggle_featured(%Post{} = post) do
    update_post(post, %{"is_featured" => !post.is_featured})
  end

  # Auto-save functionality
  
  def auto_save_draft(draft_id, draft_params, user_id) do
    draft = get_draft!(draft_id)
    
    # Start a transaction to update draft and create revision
    Repo.transaction(fn ->
      # Create a revision for history
      revision_attrs = Map.merge(draft_params, %{
        "draft_id" => draft_id,
        "user_id" => user_id,
        "auto_saved" => true,
        "revision_note" => "Auto-saved"
      })
      
      case %DraftRevision{}
           |> DraftRevision.changeset(revision_attrs)
           |> Repo.insert() do
        {:ok, _revision} ->
          # Update the draft with new content and increment revision count
          update_attrs = Map.merge(draft_params, %{
            "last_auto_save_at" => DateTime.utc_now(),
            "revision_count" => draft.revision_count + 1
          })
          
          case update_draft(draft, update_attrs) do
            {:ok, updated_draft} -> updated_draft
            {:error, changeset} -> Repo.rollback(changeset)
          end
          
        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end
  
  def create_draft_with_auto_save(draft_params, user_id) do
    # Start a transaction to create draft and initial revision
    Repo.transaction(fn ->
      # Add auto-save timestamp
      draft_params = Map.merge(draft_params, %{
        "last_auto_save_at" => DateTime.utc_now(),
        "revision_count" => 1
      })
      
      # Create the draft
      case save_draft(draft_params) do
        %Draft{} = draft ->
          # Create initial revision
          revision_attrs = Map.merge(draft_params, %{
            "draft_id" => draft.id,
            "user_id" => user_id,
            "auto_saved" => true,
            "revision_note" => "Initial auto-save"
          })
          
          case %DraftRevision{}
               |> DraftRevision.changeset(revision_attrs)
               |> Repo.insert() do
            {:ok, _revision} -> draft
            {:error, changeset} -> Repo.rollback(changeset)
          end
          
        error ->
          Repo.rollback(error)
      end
    end)
  end
  
  def list_draft_revisions(draft_id, limit \\ 20) do
    DraftRevision
    |> where([r], r.draft_id == ^draft_id)
    |> order_by([r], desc: r.inserted_at)
    |> limit(^limit)
    |> preload(:user)
    |> Repo.all()
  end
  
  def get_draft_revision!(id) do
    DraftRevision
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end
  
  def restore_draft_from_revision(draft_id, revision_id, user_id) do
    revision = get_draft_revision!(revision_id)
    
    if revision.draft_id == draft_id do
      draft = get_draft!(draft_id)
      
      # Create a new revision for the current state before restoring
      backup_attrs = %{
        "draft_id" => draft_id,
        "user_id" => user_id,
        "title" => draft.title,
        "body" => draft.body,
        "raw_body" => draft.raw_body,
        "slug" => draft.slug,
        "publishedDate" => draft.publishedDate,
        "meta_description" => draft.meta_description,
        "meta_keywords" => draft.meta_keywords,
        "og_title" => draft.og_title,
        "og_description" => draft.og_description,
        "og_image" => draft.og_image,
        "twitter_card_type" => draft.twitter_card_type,
        "canonical_url" => draft.canonical_url,
        "seo_data" => draft.seo_data,
        "is_featured" => draft.is_featured,
        "category_id" => draft.category_id,
        "series_id" => draft.series_id,
        "series_position" => draft.series_position,
        "revision_note" => "Before restoring from revision ##{revision.id}",
        "auto_saved" => false
      }
      
      Repo.transaction(fn ->
        # Save current state as a revision
        case %DraftRevision{}
             |> DraftRevision.changeset(backup_attrs)
             |> Repo.insert() do
          {:ok, _backup} ->
            # Restore from the selected revision
            restore_attrs = %{
              "title" => revision.title,
              "body" => revision.body,
              "raw_body" => revision.raw_body,
              "slug" => revision.slug,
              "publishedDate" => revision.publishedDate,
              "meta_description" => revision.meta_description,
              "meta_keywords" => revision.meta_keywords,
              "og_title" => revision.og_title,
              "og_description" => revision.og_description,
              "og_image" => revision.og_image,
              "twitter_card_type" => revision.twitter_card_type,
              "canonical_url" => revision.canonical_url,
              "seo_data" => revision.seo_data,
              "is_featured" => revision.is_featured,
              "category_id" => revision.category_id,
              "series_id" => revision.series_id,
              "series_position" => revision.series_position,
              "revision_count" => draft.revision_count + 1
            }
            
            case update_draft(draft, restore_attrs) do
              {:ok, updated_draft} -> updated_draft
              {:error, changeset} -> Repo.rollback(changeset)
            end
            
          {:error, changeset} ->
            Repo.rollback(changeset)
        end
      end)
    else
      {:error, :unauthorized}
    end
  end

end
