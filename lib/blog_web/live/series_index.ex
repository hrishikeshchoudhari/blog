defmodule BlogWeb.SeriesIndex do
  use BlogWeb, :live_view
  alias Blog.Landing
  import BlogWeb.LiveHelpers
  
  def mount(_params, _session, socket) do
    series = Landing.all_series()
    
    socket =
      socket
      |> assign_sidebar_data()
      |> assign(
        series_list: series,
        active_nav: :writing,
        page_title: "All Series"
      )
    
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div class="series-index">
      <div class="mb-12">
        <h1 class="text-5xl font-bold mb-4 text-neutral-850 font-snpro tracking-tight">Post Series</h1>
        <p class="text-xl text-gray-600">Explore comprehensive series on various topics</p>
      </div>
      
      <div class="grid gap-8">
        <%= for series <- @series_list do %>
          <div class="series-card bg-white rounded-lg shadow-lg hover:shadow-xl transition-shadow overflow-hidden">
            <div class="flex flex-col lg:flex-row">
              <%= if series.cover_image do %>
                <div class="lg:w-1/3">
                  <img src={series.cover_image} alt={series.title} class="w-full h-48 lg:h-full object-cover" />
                </div>
              <% end %>
              <div class={"p-8 " <> if series.cover_image, do: "lg:w-2/3", else: "w-full"}>
                <h2 class="text-3xl font-bold mb-3 font-snpro tracking-tight">
                  <.link navigate={"/series/" <> series.slug} class="hover:text-orange-600 transition-colors">
                    <%= series.title %>
                  </.link>
                </h2>
                <p class="text-gray-700 mb-4 text-lg"><%= series.description %></p>
                <div class="flex items-center gap-6 text-sm text-gray-600 mb-6">
                  <span class="flex items-center gap-2">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                    <%= length(series.posts) %> posts
                  </span>
                  <span class="flex items-center gap-2">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <%= calculate_series_reading_time(series.posts) %> min total
                  </span>
                  <span class="flex items-center gap-2">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    Started <%= format_date(series.inserted_at) %>
                  </span>
                </div>
                <div class="flex flex-wrap gap-2 mb-6">
                  <%= for {post, index} <- Enum.with_index(series.posts) do %>
                    <div class="text-sm bg-gray-100 rounded-full px-3 py-1">
                      Part <%= index + 1 %>: <%= String.slice(post.title, 0, 30) %><%= if String.length(post.title) > 30, do: "..." %>
                    </div>
                  <% end %>
                </div>
                <.link 
                  navigate={"/series/" <> series.slug} 
                  class="inline-flex items-center gap-2 text-orange-600 hover:text-orange-700 font-medium"
                >
                  Start reading 
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                  </svg>
                </.link>
              </div>
            </div>
          </div>
        <% end %>
        
        <%= if @series_list == [] do %>
          <div class="text-center py-16">
            <svg class="w-16 h-16 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
            </svg>
            <h3 class="text-xl font-medium text-gray-600 mb-2">No series yet</h3>
            <p class="text-gray-500">Check back later for comprehensive post series.</p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
  
  defp calculate_series_reading_time(posts) do
    posts
    |> Enum.map(&estimate_reading_time(&1.body))
    |> Enum.sum()
  end
  
  defp estimate_reading_time(content) do
    plain_text = content 
      |> String.replace(~r/<[^>]*>/, " ")
      |> String.replace(~r/\s+/, " ")
    
    word_count = plain_text |> String.split() |> length()
    max(1, div(word_count, 200))
  end
  
  defp format_date(date) do
    Calendar.strftime(date, "%B %Y")
  end
end