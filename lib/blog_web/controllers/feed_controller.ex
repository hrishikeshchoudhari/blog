defmodule BlogWeb.FeedController do
  use BlogWeb, :controller
  alias Blog.Feed
  
  @doc """
  Serves the main Atom/RSS feed for all blog posts.
  """
  def index(conn, params) do
    limit = parse_limit(params["limit"])
    
    conn
    |> put_resp_content_type("application/atom+xml")
    |> send_resp(200, Feed.generate_main_feed(limit))
  end
  
  @doc """
  Serves the RSS feed (same as Atom feed in our implementation).
  """
  def rss(conn, params) do
    # Redirect to the main feed or serve the same content
    index(conn, params)
  end
  
  @doc """
  Serves the Atom feed for a specific category.
  """
  def category(conn, %{"slug" => slug} = params) do
    limit = parse_limit(params["limit"])
    
    try do
      feed_content = Feed.generate_category_feed(slug, limit)
      
      conn
      |> put_resp_content_type("application/atom+xml")
      |> send_resp(200, feed_content)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> put_view(BlogWeb.ErrorView)
        |> render("404.html")
    end
  end
  
  @doc """
  Serves the Atom feed for a specific series.
  """
  def series(conn, %{"slug" => slug}) do
    try do
      feed_content = Feed.generate_series_feed(slug)
      
      conn
      |> put_resp_content_type("application/atom+xml")
      |> send_resp(200, feed_content)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> put_view(BlogWeb.ErrorView)
        |> render("404.html")
    end
  end
  
  @doc """
  Serves the Atom feed for a specific tag.
  """
  def tag(conn, %{"slug" => slug} = params) do
    limit = parse_limit(params["limit"])
    
    try do
      feed_content = Feed.generate_tag_feed(slug, limit)
      
      conn
      |> put_resp_content_type("application/atom+xml")
      |> send_resp(200, feed_content)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> put_view(BlogWeb.ErrorView)
        |> render("404.html")
    end
  end
  
  @doc """
  Serves OPML file listing all available feeds.
  """
  def opml(conn, _params) do
    categories = Blog.Landing.all_categories()
    series = Blog.Landing.all_series()
    tags = Blog.Landing.all_tags()
    
    opml_content = generate_opml(categories, series, tags)
    
    conn
    |> put_resp_content_type("application/xml")
    |> put_resp_header("content-disposition", "attachment; filename=\"blog-feeds.opml\"")
    |> send_resp(200, opml_content)
  end
  
  # Private functions
  
  defp parse_limit(nil), do: 20
  defp parse_limit(limit_str) do
    case Integer.parse(limit_str) do
      {limit, _} when limit > 0 and limit <= 100 -> limit
      _ -> 20
    end
  end
  
  defp generate_opml(categories, series, tags) do
    site_url = Application.get_env(:blog, :site_url, "http://localhost:4000")
    
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <opml version="2.0">
      <head>
        <title>Blog Feeds</title>
        <dateCreated>#{DateTime.utc_now() |> DateTime.to_iso8601()}</dateCreated>
      </head>
      <body>
        <outline text="All Feeds" title="All Feeds">
          <outline type="rss" text="Main Feed" title="Main Feed" xmlUrl="#{site_url}/feed.xml" htmlUrl="#{site_url}"/>
          
          <outline text="Categories" title="Categories">
            #{Enum.map_join(categories, "\n", &category_opml_outline(&1, site_url))}
          </outline>
          
          <outline text="Series" title="Series">
            #{Enum.map_join(series, "\n", &series_opml_outline(&1, site_url))}
          </outline>
          
          <outline text="Tags" title="Tags">
            #{Enum.map_join(tags, "\n", &tag_opml_outline(&1, site_url))}
          </outline>
        </outline>
      </body>
    </opml>
    """
  end
  
  defp category_opml_outline(category, site_url) do
    ~s(<outline type="rss" text="#{escape_xml(category.name)}" title="#{escape_xml(category.name)}" xmlUrl="#{site_url}/category/#{category.slug}/feed.xml" htmlUrl="#{site_url}/category/#{category.slug}"/>)
  end
  
  defp series_opml_outline(series, site_url) do
    ~s(<outline type="rss" text="#{escape_xml(series.title)}" title="#{escape_xml(series.title)}" xmlUrl="#{site_url}/series/#{series.slug}/feed.xml" htmlUrl="#{site_url}/series/#{series.slug}"/>)
  end
  
  defp tag_opml_outline(tag, site_url) do
    ~s(<outline type="rss" text="##{escape_xml(tag.name)}" title="##{escape_xml(tag.name)}" xmlUrl="#{site_url}/tag/#{tag.slug}/feed.xml" htmlUrl="#{site_url}/tag/#{tag.slug}"/>)
  end
  
  defp escape_xml(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end
end