defmodule BlogWeb.Helpers.TocHelper do
  @moduledoc """
  Helper functions for generating table of contents from markdown content.
  """
  
  def generate_toc(markdown_content) when is_binary(markdown_content) do
    headings = extract_headings(markdown_content)
    
    if length(headings) >= 3 do
      build_toc_html(headings)
    else
      nil
    end
  end
  
  def generate_toc(_), do: nil
  
  defp extract_headings(content) do
    # Match markdown headings (##, ###, ####)
    ~r/^(\#{2,4})\s+(.+)$/m
    |> Regex.scan(content)
    |> Enum.map(fn [_full, hashes, title] ->
      level = String.length(hashes)
      slug = slugify(title)
      %{level: level, title: String.trim(title), slug: slug}
    end)
  end
  
  defp slugify(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.trim("-")
  end
  
  defp build_toc_html(headings) do
    """
    <nav class="toc">
      <h3 class="toc-title">Table of Contents</h3>
      <ul class="toc-list">
        #{Enum.map_join(headings, "\n", &heading_to_html/1)}
      </ul>
    </nav>
    """
  end
  
  defp heading_to_html(%{level: level, title: title, slug: slug}) do
    indent_class = "toc-level-#{level}"
    ~s(<li class="#{indent_class}"><a href="##{slug}">#{title}</a></li>)
  end
  
  @doc """
  Adds IDs to headings in HTML content for TOC linking
  """
  def add_heading_ids(html_content) when is_binary(html_content) do
    # Match HTML headings and add IDs
    Regex.replace(
      ~r/<h([2-4])>(.+?)<\/h\1>/,
      html_content,
      fn _, level, content ->
        clean_content = strip_html_tags(content)
        id = slugify(clean_content)
        ~s(<h#{level} id="#{id}">#{content}</h#{level}>)
      end
    )
  end
  
  def add_heading_ids(content), do: content
  
  defp strip_html_tags(text) do
    Regex.replace(~r/<[^>]+>/, text, "")
  end
end