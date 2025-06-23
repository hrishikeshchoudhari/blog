defmodule BlogWeb.Components.Pagination do
  use Phoenix.Component
  import BlogWeb.CoreComponents

  @doc """
  Renders pagination controls.
  
  ## Examples
  
      <.pagination page={@page} total_pages={@total_pages} total_items={@total_posts} base_url="/" />
      <.pagination page={@page} total_pages={@total_pages} total_items={@total_posts} base_url="/tag/elixir" />
  """
  attr :page, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :total_items, :integer, required: true
  attr :base_url, :string, required: true
  attr :item_name, :string, default: "posts"

  def pagination(assigns) do
    ~H"""
    <%= if @total_pages > 1 do %>
      <div class="flex justify-center items-center space-x-2 mt-16 mb-8" phx-hook="ScrollToTop" id={"pagination-#{@base_url |> String.replace("/", "-") |> String.replace("?", "-")}-#{@page}"} data-page={@page}>
        <!-- Previous Page -->
        <%= if @page > 1 do %>
          <.link 
            patch={build_page_url(@base_url, @page - 1)}
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
          >
            ← Previous
          </.link>
        <% else %>
          <span class="px-4 py-2 text-sm font-medium text-gray-400 bg-gray-100 border border-gray-200 rounded-md cursor-not-allowed">
            ← Previous
          </span>
        <% end %>
        
        <!-- Page Numbers -->
        <div class="flex space-x-1">
          <%= for page_num <- pagination_range(@page, @total_pages) do %>
            <%= if page_num == "..." do %>
              <span class="px-3 py-2 text-sm text-gray-500">...</span>
            <% else %>
              <%= if page_num == @page do %>
                <span class="px-3 py-2 text-sm font-medium text-white bg-lava rounded-md">
                  <%= page_num %>
                </span>
              <% else %>
                <.link 
                  patch={build_page_url(@base_url, page_num)}
                  class="px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
                >
                  <%= page_num %>
                </.link>
              <% end %>
            <% end %>
          <% end %>
        </div>
        
        <!-- Next Page -->
        <%= if @page < @total_pages do %>
          <.link 
            patch={build_page_url(@base_url, @page + 1)}
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Next →
          </.link>
        <% else %>
          <span class="px-4 py-2 text-sm font-medium text-gray-400 bg-gray-100 border border-gray-200 rounded-md cursor-not-allowed">
            Next →
          </span>
        <% end %>
      </div>
      
      <div class="text-center text-sm text-gray-600 mb-8">
        Page <%= @page %> of <%= @total_pages %> • Total <%= @item_name %>: <%= @total_items %>
      </div>
    <% end %>
    """
  end
  
  defp pagination_range(current_page, total_pages) when total_pages <= 7 do
    1..total_pages |> Enum.to_list()
  end
  
  defp pagination_range(current_page, total_pages) do
    cond do
      # Near the beginning
      current_page <= 4 ->
        [1, 2, 3, 4, 5, "...", total_pages]
        
      # Near the end
      current_page >= total_pages - 3 ->
        [1, "...", total_pages - 4, total_pages - 3, total_pages - 2, total_pages - 1, total_pages]
        
      # In the middle
      true ->
        [1, "...", current_page - 1, current_page, current_page + 1, "...", total_pages]
    end
  end
  
  defp build_page_url(base_url, page) do
    if String.contains?(base_url, "?") do
      "#{base_url}&page=#{page}"
    else
      "#{base_url}?page=#{page}"
    end
  end
end