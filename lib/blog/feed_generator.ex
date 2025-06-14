defmodule Blog.FeedGenerator do
  @moduledoc """
  Custom Atom feed generator that doesn't rely on xml_builder.
  """
  
  def generate({:feed, attrs, children}) do
    """
    <?xml version="1.0" encoding="utf-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      #{generate_elements(children)}
    </feed>
    """
  end
  
  def generate(feed) when is_map(feed) do
    # Fallback for map-based feeds
    """
    <?xml version="1.0" encoding="utf-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      #{generate_feed_metadata(feed)}
      #{generate_entries(feed.entries)}
    </feed>
    """
  end
  
  defp generate_feed_metadata(feed) do
    """
      <id>#{escape_xml(feed.id)}</id>
      <title type="#{escape_xml(feed.title_type || "text")}">#{escape_xml(feed.title)}</title>
      <updated>#{format_datetime(feed.updated)}</updated>
      #{generate_links(feed.links)}
      #{generate_authors(feed.authors)}
      #{if feed.subtitle, do: "<subtitle>#{escape_xml(feed.subtitle)}</subtitle>", else: ""}
      #{if feed.generator, do: generate_generator(feed.generator), else: ""}
    """
  end
  
  defp generate_entries(entries) do
    entries
    |> Enum.map(&generate_entry/1)
    |> Enum.join("\n")
  end
  
  defp generate_entry(entry) do
    """
      <entry>
        <id>#{escape_xml(entry.id)}</id>
        <title type="#{escape_xml(entry.title_type || "text")}">#{escape_xml(entry.title)}</title>
        <updated>#{format_datetime(entry.updated)}</updated>
        #{if entry.published, do: "<published>#{format_datetime(entry.published)}</published>", else: ""}
        #{generate_links(entry.links)}
        #{generate_authors(entry.authors)}
        #{if entry.summary, do: "<summary type=\"#{escape_xml(entry.summary_type || "text")}\">#{escape_xml(entry.summary)}</summary>", else: ""}
        #{if entry.content, do: generate_content(entry.content, entry.content_type), else: ""}
        #{generate_categories(entry.categories)}
      </entry>
    """
  end
  
  defp generate_links(links) do
    links
    |> Enum.map(fn link ->
      attrs = [
        ~s(href="#{escape_xml(link.href)}"),
        if(link.rel, do: ~s(rel="#{escape_xml(link.rel)}"), else: nil),
        if(link.type, do: ~s(type="#{escape_xml(link.type)}"), else: nil),
        if(link.hreflang, do: ~s(hreflang="#{escape_xml(link.hreflang)}"), else: nil),
        if(link.title, do: ~s(title="#{escape_xml(link.title)}"), else: nil),
        if(link.length, do: ~s(length="#{link.length}"), else: nil)
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")
      
      "<link #{attrs}/>"
    end)
    |> Enum.join("\n      ")
  end
  
  defp generate_authors(authors) do
    authors
    |> Enum.map(fn author ->
      """
        <author>
          <name>#{escape_xml(author.name)}</name>
          #{if author.email, do: "<email>#{escape_xml(author.email)}</email>", else: ""}
          #{if author.uri, do: "<uri>#{escape_xml(author.uri)}</uri>", else: ""}
        </author>
      """
    end)
    |> Enum.join()
  end
  
  defp generate_generator(generator) do
    attrs = []
    attrs = if generator.uri, do: [~s(uri="#{escape_xml(generator.uri)}") | attrs], else: attrs
    attrs = if generator.version, do: [~s(version="#{escape_xml(generator.version)}") | attrs], else: attrs
    attrs_str = if attrs != [], do: " " <> Enum.join(attrs, " "), else: ""
    
    "<generator#{attrs_str}>#{escape_xml(generator.name)}</generator>"
  end
  
  defp generate_content(content, type) do
    type_attr = type || "text"
    "<content type=\"#{escape_xml(type_attr)}\">#{escape_xml(content)}</content>"
  end
  
  defp generate_categories(categories) do
    categories
    |> Enum.map(fn category ->
      attrs = [
        ~s(term="#{escape_xml(category.term)}"),
        if(category.scheme, do: ~s(scheme="#{escape_xml(category.scheme)}"), else: nil),
        if(category.label, do: ~s(label="#{escape_xml(category.label)}"), else: nil)
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")
      
      "<category #{attrs}/>"
    end)
    |> Enum.join("\n        ")
  end
  
  defp format_datetime(%DateTime{} = dt) do
    DateTime.to_iso8601(dt)
  end
  defp format_datetime(_), do: DateTime.to_iso8601(DateTime.utc_now())
  
  defp escape_xml(nil), do: ""
  defp escape_xml(text) when is_binary(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end
  defp escape_xml(value), do: escape_xml(to_string(value))
  
  defp escape_html_for_xml(html) do
    # For HTML content in XML, we need to escape XML entities but preserve HTML structure
    # This is already escaped HTML, so we just need to ensure it's valid
    html
  end
  
  defp generate_elements(elements) do
    elements
    |> Enum.map(&generate_element/1)
    |> Enum.join("\n      ")
  end
  
  defp generate_element({:entry, attrs, children}) do
    "<entry>\n        #{generate_elements(children)}\n      </entry>"
  end
  
  defp generate_element({:id, _attrs, content}) do
    "<id>#{escape_xml(content)}</id>"
  end
  
  defp generate_element({:title, attrs, content}) do
    type = attrs[:type] || "text"
    "<title type=\"#{escape_xml(type)}\">#{escape_xml(content)}</title>"
  end
  
  defp generate_element({:updated, _attrs, content}) do
    "<updated>#{escape_xml(content)}</updated>"
  end
  
  defp generate_element({:published, _attrs, content}) do
    "<published>#{escape_xml(content)}</published>"
  end
  
  defp generate_element({:link, attrs, _content}) do
    attr_string = attrs
    |> Enum.map(fn {k, v} -> "#{k}=\"#{escape_xml(v)}\"" end)
    |> Enum.join(" ")
    "<link #{attr_string}/>"
  end
  
  defp generate_element({:author, _attrs, children}) do
    "<author>\n          #{generate_elements(children)}\n        </author>"
  end
  
  defp generate_element({:name, _attrs, content}) do
    "<name>#{escape_xml(content)}</name>"
  end
  
  defp generate_element({:email, _attrs, content}) do
    "<email>#{escape_xml(content)}</email>"
  end
  
  defp generate_element({:summary, attrs, content}) do
    type = attrs[:type] || "text"
    "<summary type=\"#{escape_xml(type)}\">#{escape_xml(content)}</summary>"
  end
  
  defp generate_element({:content, attrs, content}) do
    type = attrs[:type] || "text"
    # For HTML content, we need to escape it but preserve valid HTML entities
    escaped_content = if type == "html" do
      escape_html_for_xml(content)
    else
      escape_xml(content)
    end
    "<content type=\"#{escape_xml(type)}\">#{escaped_content}</content>"
  end
  
  defp generate_element({:category, attrs, _content}) do
    attr_string = attrs
    |> Enum.map(fn {k, v} -> "#{k}=\"#{escape_xml(v)}\"" end)
    |> Enum.join(" ")
    "<category #{attr_string}/>"
  end
  
  defp generate_element({:generator, attrs, content}) do
    attr_string = case attrs do
      nil -> ""
      [] -> ""
      attrs when is_list(attrs) ->
        attrs
        |> Enum.map(fn {k, v} -> "#{k}=\"#{escape_xml(v)}\"" end)
        |> Enum.join(" ")
        |> then(fn s -> " " <> s end)
    end
    "<generator#{attr_string}>#{escape_xml(content)}</generator>"
  end
  
  defp generate_element({:subtitle, attrs, content}) do
    type = if is_map(attrs), do: attrs[:type], else: "text"
    "<subtitle type=\"#{escape_xml(type || "text")}\">#{escape_xml(content)}</subtitle>"
  end
  
  defp generate_element({tag, attrs, content}) do
    # Generic handler for any other elements
    attr_string = case attrs do
      nil -> ""
      attrs when is_map(attrs) ->
        attrs
        |> Enum.map(fn {k, v} -> "#{k}=\"#{escape_xml(v)}\"" end)
        |> Enum.join(" ")
        |> then(fn s -> if s == "", do: "", else: " " <> s end)
      attrs when is_list(attrs) ->
        attrs
        |> Enum.map(fn {k, v} -> "#{k}=\"#{escape_xml(v)}\"" end)
        |> Enum.join(" ")
        |> then(fn s -> if s == "", do: "", else: " " <> s end)
    end
    
    if content do
      "<#{tag}#{attr_string}>#{escape_xml(content)}</#{tag}>"
    else
      "<#{tag}#{attr_string}/>"
    end
  end
end