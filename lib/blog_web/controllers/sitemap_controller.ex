defmodule BlogWeb.SitemapController do
  use BlogWeb, :controller
  
  alias Blog.Landing
  alias BlogWeb.Endpoint
  
  def index(conn, _params) do
    posts = Landing.all_posts()
    tags = Landing.all_tags()
    
    # Build the sitemap XML
    sitemap = build_sitemap(posts, tags)
    
    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, sitemap)
  end
  
  defp build_sitemap(posts, tags) do
    base_url = Endpoint.url()
    
    urlset = [
      # Home page
      build_url(base_url, "/", "1.0", "daily"),
      
      # About page
      build_url(base_url, "/about", "0.8", "monthly"),
      
      # Individual posts
      Enum.map(posts, fn post ->
        build_url(
          base_url, 
          "/post/#{post.slug}", 
          "0.8", 
          "yearly",
          post.updated_at || post.inserted_at
        )
      end),
      
      # Tag pages
      Enum.map(tags, fn tag ->
        build_url(base_url, "/tag/#{tag.slug}", "0.6", "weekly")
      end)
    ]
    |> List.flatten()
    
    # Build XML
    {:urlset, %{xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9"}, urlset}
    |> XmlBuilder.generate()
  end
  
  defp build_url(base_url, path, priority, changefreq, lastmod \\ nil) do
    url_elements = [
      {:loc, nil, base_url <> path},
      {:changefreq, nil, changefreq},
      {:priority, nil, priority}
    ]
    
    # Add lastmod if provided
    url_elements = if lastmod do
      url_elements ++ [{:lastmod, nil, format_date(lastmod)}]
    else
      url_elements
    end
    
    {:url, nil, url_elements}
  end
  
  defp format_date(%DateTime{} = date) do
    Timex.format!(date, "{YYYY}-{0M}-{0D}")
  end
  
  defp format_date(_), do: nil
end