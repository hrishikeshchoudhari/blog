defmodule BlogWeb.SeriesShow do
  use BlogWeb, :live_view
  alias Blog.Landing
  import BlogWeb.LiveHelpers
  import BlogWeb.Components.Pagination
  
  def mount(params, _session, socket) do
    %{"slug" => slug} = params
    page = String.to_integer(params["page"] || "1")
    
    paginated_data = Landing.list_posts_by_series_slug(slug, page, 10)
    
    if paginated_data.series do
      socket =
        socket
        |> assign_sidebar_data()
        |> assign(
          current_series_data: paginated_data.series,
          posts: paginated_data.posts,
          page: paginated_data.page,
          total_pages: paginated_data.total_pages,
          total_posts: paginated_data.total_posts,
          active_nav: :writing,
          page_title: paginated_data.series.title,
          current_series: paginated_data.series,
          feed_url: "/series/#{slug}/feed.xml",
          feed_title: "#{paginated_data.series.title} - Blog Feed"
        )
      
      {:ok, socket}
    else
      {:ok, push_navigate(socket, to: "/series")}
    end
  end
  
  def handle_params(params, _uri, socket) do
    %{"slug" => slug} = params
    page = String.to_integer(params["page"] || "1")
    
    paginated_data = Landing.list_posts_by_series_slug(slug, page, 10)
    
    {:noreply, 
      socket
      |> assign(
        posts: paginated_data.posts,
        page: paginated_data.page,
        total_pages: paginated_data.total_pages,
        total_posts: paginated_data.total_posts
      )
    }
  end
  
  def render(assigns) do
    ~H"""
    <div class="series-show">
      <!-- Series Header -->
      <div class="mb-12 pb-8 border-b border-gray-200">
        <h1 class="text-5xl font-bold mb-4 text-neutral-850 font-snpro tracking-tight">
          <%= @current_series_data.title %>
        </h1>
        <p class="text-xl text-gray-700 mb-6"><%= @current_series_data.description %></p>
        
        <div class="flex flex-wrap items-center gap-6 text-sm text-gray-600">
          <span class="flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <%= @total_posts %> posts in this series
          </span>
          <span class="flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            ~<%= calculate_total_reading_time(@total_posts, 200) %> min total reading time
          </span>
        </div>
      </div>
      
      <!-- Series Posts -->
      <div class="space-y-8">
        <%= for {post, index} <- Enum.with_index(@posts) do %>
          <article class="bg-white rounded-lg shadow hover:shadow-lg transition-shadow p-6 relative">
            <!-- Part Number Badge -->
            <div class="absolute -top-3 -left-3 bg-orange-600 text-white rounded-full w-12 h-12 flex items-center justify-center font-bold">
              <%= index + 1 + ((@page - 1) * 10) %>
            </div>
            
            <div class="ml-6">
              <h2 class="text-2xl font-bold mb-3 font-snpro tracking-tight">
                <.link navigate={"/post/" <> post.slug} class="hover:text-orange-600 transition-colors">
                  <%= post.title %>
                </.link>
              </h2>
              
              <div class="flex items-center gap-4 text-sm text-gray-600 mb-4">
                <%= if post.category do %>
                  <.link navigate={"/category/" <> post.category.slug} class="text-orange-600 hover:text-orange-700">
                    <%= post.category.name %>
                  </.link>
                <% end %>
                <span><%= Calendar.strftime(post.publishedDate, "%B %d, %Y") %></span>
                <span><%= estimate_reading_time(post.body) %> min read</span>
              </div>
              
              <%= if post.meta_description do %>
                <p class="text-gray-700 mb-4"><%= post.meta_description %></p>
              <% end %>
              
              <%= if post.tags != [] do %>
                <div class="flex flex-wrap gap-2">
                  <%= for tag <- post.tags do %>
                    <.link 
                      navigate={"/tag/" <> tag.slug} 
                      class="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 hover:bg-gray-300"
                    >
                      #<%= tag.name %>
                    </.link>
                  <% end %>
                </div>
              <% end %>
            </div>
          </article>
        <% end %>
      </div>
      
      <!-- Pagination Controls -->
      <.pagination 
        page={@page} 
        total_pages={@total_pages} 
        total_items={@total_posts} 
        base_url={"/series/#{@current_series_data.slug}"} 
      />
      
      <!-- Series Navigation -->
      <div class="mt-12 pt-8 border-t border-gray-200">
        <div class="flex justify-between items-center">
          <.link navigate="/series" class="inline-flex items-center gap-2 text-orange-600 hover:text-orange-700 font-medium">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
            Back to all series
          </.link>
          
          <%= if @total_posts > 0 && @page == 1 && length(@posts) > 0 do %>
            <.link 
              navigate={"/post/" <> hd(@posts).slug} 
              class="inline-flex items-center gap-2 bg-orange-600 text-white px-6 py-3 rounded-lg hover:bg-orange-700 transition-colors font-medium"
            >
              Start reading from Part 1
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
  
  defp calculate_total_reading_time(total_posts, avg_words_per_post) do
    # Rough estimate based on average post length
    total_words = total_posts * avg_words_per_post
    max(total_posts, div(total_words, 200))
  end
  
  defp estimate_reading_time(content) do
    plain_text = content 
      |> String.replace(~r/<[^>]*>/, " ")
      |> String.replace(~r/\s+/, " ")
    
    word_count = plain_text |> String.split() |> length()
    max(1, div(word_count, 200))
  end
end