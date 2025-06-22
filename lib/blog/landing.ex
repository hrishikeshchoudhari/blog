defmodule Blog.Landing do
  @moduledoc """
  The Landing context
  """
  import Ecto.Query, warn: false
  alias Blog.{Post, Page}
  alias Blog.Admin.{Tag, Category, Series}
  alias Blog.Repo
  require Logger

  def all_posts() do
    Post
    |> where([p], p.post_type == "post")
    |> preload([:tags, :category, :series])
    |> order_by([p], desc: p.publishedDate)
    |> Repo.all()
  end
  
  def all_projects() do
    Post
    |> where([p], p.post_type == "project")
    |> preload([:tags, :category, :series])
    |> order_by([p], desc: p.publishedDate)
    |> Repo.all()
  end
  
  def all_readings() do
    Post
    |> where([p], p.post_type == "reading")
    |> preload([:tags, :category, :series])
    |> order_by([p], desc: p.date_read)
    |> Repo.all()
  end

  def all_tags do
    Repo.all(Tag)
  end

  def get_post_by_slug(slug) do
    Post
    |> preload([:tags, :category, series: :posts])
    |> Repo.get_by(slug: slug)
  end

  def get_posts_by_tag_slug(tag_slug, post_type \\ nil) do
    tag = Repo.get_by(Tag, slug: tag_slug)
    
    if tag do
      query = if post_type do
        from(p in Post, where: p.post_type == ^post_type, order_by: [desc: p.publishedDate], preload: [:tags, :category, :series])
      else
        from(p in Post, order_by: [desc: p.publishedDate], preload: [:tags, :category, :series])
      end
      
      tag
      |> Repo.preload(posts: query)
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
  
  def featured_posts(limit \\ 3, post_type \\ "post") do
    Post
    |> where([p], p.is_featured == true and p.post_type == ^post_type)
    |> preload([:tags, :category, :series])
    |> order_by([p], desc: p.publishedDate)
    |> limit(^limit)
    |> Repo.all()
  end
  
  def all_categories do
    Category
    |> where([c], is_nil(c.parent_id))
    |> preload(:children)
    |> order_by([c], asc: c.name)
    |> Repo.all()
  end
  
  def get_category_by_slug(slug) do
    Category
    |> preload([:parent, :children, posts: [:tags, :category]])
    |> Repo.get_by(slug: slug)
  end
  
  def all_series do
    Series
    |> preload([posts: [:tags, :category]])
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end
  
  def get_series_by_slug(slug) do
    Series
    |> preload(posts: [:tags, :category])
    |> Repo.get_by(slug: slug)
  end
  
  def popular_series(limit \\ 3) do
    Series
    |> join(:left, [s], p in assoc(s, :posts))
    |> group_by([s], s.id)
    |> having([s, p], count(p.id) > 0)
    |> order_by([s, p], desc: count(p.id))
    |> limit(^limit)
    |> preload([:posts])
    |> Repo.all()
  end
end
