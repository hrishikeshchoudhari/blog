defmodule Blog.Landing do
  @moduledoc """
  The Landing context
  """
  import Ecto.Query, warn: false
  alias Blog.{Post, Page}
  alias Blog.Admin.Tag
  alias Blog.Repo
  require Logger

  def all_posts() do
    Post
    |> preload(:tags)
    |> order_by([p], desc: p.publishedDate)
    |> Repo.all()
  end

  def all_tags do
    Repo.all(Tag)
  end

  def get_post_by_slug(slug) do
    Post
    |> preload(:tags)
    |> Repo.get_by(slug: slug)
  end

  def get_posts_by_tag_slug(tag_slug) do
    tag = Repo.get_by(Tag, slug: tag_slug)
    
    if tag do
      tag
      |> Repo.preload(posts: from(p in Post, order_by: [desc: p.publishedDate], preload: :tags))
      |> Map.get(:posts, [])
    else
      []
    end
  end

  def about() do
    {}
  end
  
  def get_page(slug) do
    Repo.get_by(Page, slug: slug)
  end
  
  def get_page!(slug) do
    Repo.get_by!(Page, slug: slug)
  end
  
  def update_page(%Page{} = page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end
  
  def list_pages do
    Repo.all(Page)
  end
end
