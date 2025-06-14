defmodule Blog.Feed do
  @moduledoc """
  The Feed context for generating RSS/Atom feeds.
  """
  
  import Ecto.Query, warn: false
  alias Blog.{Repo, Post}
  alias Blog.Admin.{Category, Series}
  alias Atomex.{Feed, Entry}
  
  defp default_feed_limit, do: Application.get_env(:blog, :feed_limit, 20)
  defp site_url, do: Application.get_env(:blog, :site_url, "http://localhost:4000")
  defp feed_author, do: Application.get_env(:blog, :feed_author, "Blog Author")
  defp feed_email, do: Application.get_env(:blog, :feed_email, "author@example.com")
  
  @doc """
  Generates the main Atom feed for all posts.
  """
  def generate_main_feed(limit \\ nil) do
    limit = limit || default_feed_limit()
    posts = fetch_recent_posts(limit)
    
    last_update = get_latest_update_time(posts)
    
    feed = Feed.new(site_url() <> "/", last_update, "Blog Feed")
    |> Feed.author(feed_author(), email: feed_email())
    |> Feed.link(site_url() <> "/feed.xml", rel: "self")
    |> Feed.link(site_url(), rel: "alternate")
    |> Feed.generator("Phoenix Blog", uri: "https://github.com/hrishikeshchoudhari/blog")
    
    entries = Enum.map(posts, &build_entry/1)
    
    feed
    |> Feed.entries(entries)
    |> Feed.build()
    |> generate_feed_xml()
  end
  
  @doc """
  Generates an Atom feed for a specific category.
  """
  def generate_category_feed(category_slug, limit \\ nil) do
    limit = limit || default_feed_limit()
    category = Repo.get_by!(Category, slug: category_slug)
    posts = fetch_category_posts(category, limit)
    
    last_update = get_latest_update_time(posts)
    
    feed = Feed.new(site_url() <> "/category/#{category_slug}", last_update, "#{category.name} - Blog Feed")
    |> Feed.author(feed_author(), email: feed_email())
    |> Feed.link(site_url() <> "/category/#{category_slug}/feed.xml", rel: "self")
    |> Feed.link(site_url() <> "/category/#{category_slug}", rel: "alternate")
    |> Feed.generator("Phoenix Blog", uri: "https://github.com/hrishikeshchoudhari/blog")
    
    feed = if category.description do
      Feed.subtitle(feed, category.description)
    else
      feed
    end
    
    entries = Enum.map(posts, &build_entry/1)
    
    feed
    |> Feed.entries(entries)
    |> Feed.build()
    |> generate_feed_xml()
  end
  
  @doc """
  Generates an Atom feed for a specific series.
  """
  def generate_series_feed(series_slug) do
    series = Repo.get_by!(Series, slug: series_slug)
    |> Repo.preload(posts: [:tags, :category])
    
    posts = series.posts
    |> Enum.sort_by(& &1.series_position, :asc)
    
    last_update = get_latest_update_time(posts)
    
    feed = Feed.new(site_url() <> "/series/#{series_slug}", last_update, "#{series.title} - Blog Series")
    |> Feed.author(feed_author(), email: feed_email())
    |> Feed.link(site_url() <> "/series/#{series_slug}/feed.xml", rel: "self")
    |> Feed.link(site_url() <> "/series/#{series_slug}", rel: "alternate")
    |> Feed.generator("Phoenix Blog", uri: "https://github.com/hrishikeshchoudhari/blog")
    
    feed = if series.description do
      Feed.subtitle(feed, series.description)
    else
      feed
    end
    
    entries = Enum.map(posts, fn post ->
      build_entry(post, series: series)
    end)
    
    feed
    |> Feed.entries(entries)
    |> Feed.build()
    |> generate_feed_xml()
  end
  
  @doc """
  Generates an RSS feed (using Atom format) for all posts.
  """
  def generate_rss_feed(limit \\ nil) do
    # Atomex generates Atom format, which is a valid RSS alternative
    # Most feed readers accept both formats
    generate_main_feed(limit)
  end
  
  @doc """
  Generates a feed for posts with a specific tag.
  """
  def generate_tag_feed(tag_slug, limit \\ nil) do
    limit = limit || default_feed_limit()
    tag = Blog.Admin.get_tag_by_slug!(tag_slug)
    |> Repo.preload(posts: [:tags, :category, :series])
    
    posts = tag.posts
    |> Enum.sort_by(& &1.publishedDate, {:desc, DateTime})
    |> Enum.take(limit)
    
    last_update = get_latest_update_time(posts)
    
    feed = Feed.new(site_url() <> "/tag/#{tag_slug}", last_update, "##{tag.name} - Blog Feed")
    |> Feed.author(feed_author(), email: feed_email())
    |> Feed.link(site_url() <> "/tag/#{tag_slug}/feed.xml", rel: "self")
    |> Feed.link(site_url() <> "/tag/#{tag_slug}", rel: "alternate")
    |> Feed.generator("Phoenix Blog", uri: "https://github.com/hrishikeshchoudhari/blog")
    
    feed = if tag.description do
      Feed.subtitle(feed, tag.description)
    else
      feed
    end
    
    entries = Enum.map(posts, &build_entry/1)
    
    feed
    |> Feed.entries(entries)
    |> Feed.build()
    |> generate_feed_xml()
  end
  
  # Private functions
  
  defp fetch_recent_posts(limit) do
    Post
    |> preload([:tags, :category, :series])
    |> order_by([p], desc: p.publishedDate)
    |> limit(^limit)
    |> Repo.all()
  end
  
  defp fetch_category_posts(category, limit) do
    Post
    |> where([p], p.category_id == ^category.id)
    |> preload([:tags, :category, :series])
    |> order_by([p], desc: p.publishedDate)
    |> limit(^limit)
    |> Repo.all()
  end
  
  defp get_latest_update_time([]), do: DateTime.utc_now()
  defp get_latest_update_time(posts) do
    posts
    |> Enum.map(& &1.updated_at)
    |> Enum.max(DateTime)
  end
  
  defp build_entry(post, opts \\ []) do
    entry = Entry.new(
      site_url() <> "/post/#{post.slug}", 
      post.updated_at, 
      post.title
    )
    |> Entry.link(site_url() <> "/post/#{post.slug}", rel: "alternate", type: "text/html")
    |> Entry.author(feed_author(), email: feed_email())
    |> Entry.published(post.publishedDate)
    
    # Add content - sanitize for feed compatibility
    content = if post.meta_description do
      "<p>#{html_escape(post.meta_description)}</p><hr/>" <> sanitize_feed_content(post.body)
    else
      sanitize_feed_content(post.body)
    end
    entry = Entry.content(entry, content, type: "html")
    
    # Add summary
    entry = if post.meta_description do
      Entry.summary(entry, post.meta_description, "text")
    else
      Entry.summary(entry, extract_summary(post.body), "text")
    end
    
    # Add categories
    entry = if post.category do
      Entry.category(entry, post.category.name, 
        term: post.category.slug,
        label: post.category.name,
        scheme: site_url() <> "/category"
      )
    else
      entry
    end
    
    # Add tags as categories
    entry = Enum.reduce(post.tags, entry, fn tag, acc ->
      Entry.category(acc, tag.name,
        term: tag.slug,
        label: tag.name,
        scheme: site_url() <> "/tag"
      )
    end)
    
    # Add series information if part of a series
    series = opts[:series] || post.series
    if series do
      entry = Entry.category(entry, "Series: #{series.title}",
        term: series.slug,
        label: series.title,
        scheme: site_url() <> "/series"
      )
      
      if post.series_position do
        summary = Map.get(entry, :summary) || ""
        Entry.summary(entry, "[Part #{post.series_position} of #{series.title}] " <> summary, "text")
      else
        entry
      end
    else
      entry
    end
    |> Entry.build()
  end
  
  defp extract_summary(html_content) do
    # Simple extraction: take first paragraph or first 160 characters
    html_content
    |> Floki.parse_document!()
    |> Floki.find("p")
    |> List.first()
    |> case do
      nil -> 
        html_content
        |> Floki.parse_document!()
        |> Floki.text()
        |> String.slice(0, 160)
        |> Kernel.<>("...")
      elem ->
        Floki.text(elem)
        |> String.slice(0, 160)
        |> then(fn text ->
          if String.length(text) == 160, do: text <> "...", else: text
        end)
    end
  end
  
  defp html_escape(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end
  
  defp sanitize_feed_content(html) do
    html
    |> remove_iframes()
    |> ensure_valid_entities()
  end
  
  defp remove_iframes(html) do
    # Remove iframe tags completely as they're not supported in feeds
    html
    |> String.replace(~r/<iframe[^>]*>.*?<\/iframe>/is, "[Embedded content removed for feed compatibility]")
    |> String.replace(~r/<iframe[^>]*\/>/is, "[Embedded content removed for feed compatibility]")
  end
  
  defp ensure_valid_entities(html) do
    # Ensure proper HTML entity encoding
    html
    |> String.replace(~r/&(?!(?:amp|lt|gt|quot|apos|#\d+|#x[0-9a-fA-F]+);)/i, "&amp;")
  end
  
  defp generate_feed_xml(feed) do
    # Use our custom feed generator
    Blog.FeedGenerator.generate(feed)
  end
  
  @doc """
  Get feed metadata for a given feed type
  """
  def get_feed_metadata(type, slug \\ nil) do
    case type do
      :main ->
        %{
          title: "Blog Feed",
          description: "Latest posts from the blog",
          url: site_url() <> "/feed.xml",
          alternate_url: site_url()
        }
        
      :category ->
        category = Repo.get_by!(Category, slug: slug)
        %{
          title: "#{category.name} - Blog Feed",
          description: category.description || "Posts in #{category.name}",
          url: site_url() <> "/category/#{slug}/feed.xml",
          alternate_url: site_url() <> "/category/#{slug}"
        }
        
      :series ->
        series = Repo.get_by!(Series, slug: slug)
        %{
          title: "#{series.title} - Blog Series",
          description: series.description,
          url: site_url() <> "/series/#{slug}/feed.xml",
          alternate_url: site_url() <> "/series/#{slug}"
        }
        
      :tag ->
        tag = Blog.Admin.get_tag_by_slug!(slug)
        %{
          title: "##{tag.name} - Blog Feed",
          description: tag.description || "Posts tagged with #{tag.name}",
          url: site_url() <> "/tag/#{slug}/feed.xml",
          alternate_url: site_url() <> "/tag/#{slug}"
        }
    end
  end
end