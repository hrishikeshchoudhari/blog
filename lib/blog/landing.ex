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
  
  def list_posts(page \\ 1, per_page \\ 10) do
    offset = (page - 1) * per_page
    
    query = 
      Post
      |> where([p], p.post_type == "post")
      |> preload([:tags, :category, :series])
      |> order_by([p], desc: p.publishedDate)
    
    posts = 
      query
      |> limit(^per_page)
      |> offset(^offset)
      |> Repo.all()
      
    total_posts = Repo.aggregate(query, :count, :id)
    total_pages = ceil(total_posts / per_page)
    
    %{
      posts: posts,
      page: page,
      per_page: per_page,
      total_posts: total_posts,
      total_pages: total_pages
    }
  end
  
  def all_projects() do
    Post
    |> where([p], p.post_type == "project")
    |> preload([:tags, :category, :series])
    |> order_by([p], desc: p.publishedDate)
    |> Repo.all()
  end
  
  def list_projects(page \\ 1, per_page \\ 12) do
    offset = (page - 1) * per_page
    
    query = 
      Post
      |> where([p], p.post_type == "project")
      |> preload([:tags, :category, :series])
      |> order_by([p], desc: p.publishedDate)
    
    projects = 
      query
      |> limit(^per_page)
      |> offset(^offset)
      |> Repo.all()
      
    total_projects = Repo.aggregate(query, :count, :id)
    total_pages = ceil(total_projects / per_page)
    
    %{
      projects: projects,
      page: page,
      per_page: per_page,
      total_projects: total_projects,
      total_pages: total_pages
    }
  end
  
  def all_readings() do
    Post
    |> where([p], p.post_type == "reading")
    |> preload([:tags, :category, :series])
    |> order_by([p], desc: p.date_read)
    |> Repo.all()
  end
  
  def list_readings(page \\ 1, per_page \\ 20) do
    offset = (page - 1) * per_page
    
    query = 
      Post
      |> where([p], p.post_type == "reading")
      |> preload([:tags, :category, :series])
      |> order_by([p], desc: p.date_read)
    
    readings = 
      query
      |> limit(^per_page)
      |> offset(^offset)
      |> Repo.all()
      
    total_readings = Repo.aggregate(query, :count, :id)
    total_pages = ceil(total_readings / per_page)
    
    # Group readings by rating for display
    readings_by_rating = Enum.group_by(readings, & &1.rating)
    
    %{
      readings: readings,
      readings_by_rating: readings_by_rating,
      page: page,
      per_page: per_page,
      total_readings: total_readings,
      total_pages: total_pages
    }
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
  
  def list_posts_by_tag_slug(tag_slug, page \\ 1, per_page \\ 10) do
    tag = Repo.get_by(Tag, slug: tag_slug)
    
    if tag do
      offset = (page - 1) * per_page
      
      # Get posts through the many-to-many relationship
      query = 
        from p in Post,
        join: pt in "posts_tags",
        on: pt.post_id == p.id,
        where: pt.tag_id == ^tag.id,
        order_by: [desc: p.publishedDate],
        preload: [:tags, :category, :series]
      
      posts = 
        query
        |> limit(^per_page)
        |> offset(^offset)
        |> Repo.all()
        
      total_posts = Repo.aggregate(query, :count, :id)
      total_pages = ceil(total_posts / per_page)
      
      %{
        posts: posts,
        tag: tag,
        page: page,
        per_page: per_page,
        total_posts: total_posts,
        total_pages: total_pages
      }
    else
      %{
        posts: [],
        tag: nil,
        page: 1,
        per_page: per_page,
        total_posts: 0,
        total_pages: 0
      }
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
  
  def list_posts_by_category_slug(category_slug, page \\ 1, per_page \\ 10) do
    category = Repo.get_by(Category, slug: category_slug)
    
    if category do
      offset = (page - 1) * per_page
      
      query = 
        from p in Post,
        where: p.category_id == ^category.id,
        order_by: [desc: p.publishedDate],
        preload: [:tags, :category, :series]
      
      posts = 
        query
        |> limit(^per_page)
        |> offset(^offset)
        |> Repo.all()
        
      total_posts = Repo.aggregate(query, :count, :id)
      total_pages = ceil(total_posts / per_page)
      
      # Load category with children but without posts for the header
      category_with_children = 
        Category
        |> preload([:parent, :children])
        |> Repo.get!(category.id)
      
      %{
        posts: posts,
        category: category_with_children,
        page: page,
        per_page: per_page,
        total_posts: total_posts,
        total_pages: total_pages
      }
    else
      %{
        posts: [],
        category: nil,
        page: 1,
        per_page: per_page,
        total_posts: 0,
        total_pages: 0
      }
    end
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
  
  def list_posts_by_series_slug(series_slug, page \\ 1, per_page \\ 10) do
    series = Repo.get_by(Series, slug: series_slug)
    
    if series do
      offset = (page - 1) * per_page
      
      query = 
        from p in Post,
        where: p.series_id == ^series.id,
        order_by: [asc: p.series_position, desc: p.publishedDate],
        preload: [:tags, :category, :series]
      
      posts = 
        query
        |> limit(^per_page)
        |> offset(^offset)
        |> Repo.all()
        
      total_posts = Repo.aggregate(query, :count, :id)
      total_pages = ceil(total_posts / per_page)
      
      %{
        posts: posts,
        series: series,
        page: page,
        per_page: per_page,
        total_posts: total_posts,
        total_pages: total_pages
      }
    else
      %{
        posts: [],
        series: nil,
        page: 1,
        per_page: per_page,
        total_posts: 0,
        total_pages: 0
      }
    end
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
