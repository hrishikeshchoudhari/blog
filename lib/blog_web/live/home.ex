defmodule BlogWeb.Home do
    use BlogWeb, :live_view
    require Logger
    alias Blog.Landing
    import BlogWeb.LiveHelpers
    import BlogWeb.Components.Pagination


    def mount(params, _session, socket) do
      page = String.to_integer(params["page"] || "1")
      per_page = 10
      
      paginated_posts = Landing.list_posts(page, per_page)
      featured_posts = Landing.featured_posts()
      popular_series = Landing.popular_series()

      socket = 
        socket
        |> assign_sidebar_data()
        |> assign(
          posts: paginated_posts.posts,
          page: paginated_posts.page,
          total_pages: paginated_posts.total_pages,
          total_posts: paginated_posts.total_posts,
          featured_posts: featured_posts,
          popular_series: popular_series,
          active_nav: :writing, 
          page_title: "All Posts"
        )

      {:ok, socket}
    end
    
    def handle_params(params, _uri, socket) do
      page = String.to_integer(params["page"] || "1")
      per_page = 10
      
      paginated_posts = Landing.list_posts(page, per_page)
      
      {:noreply, 
        socket
        |> assign(
          posts: paginated_posts.posts,
          page: paginated_posts.page,
          total_pages: paginated_posts.total_pages,
          total_posts: paginated_posts.total_posts
        )
      }
    end

    def render(assigns) do
      ~H"""
      <!-- Featured Posts Section -->
      <%= if @featured_posts != [] do %>
        <div class="featured-posts mb-16">
          <h2 class="text-3xl font-bold mb-8 text-neutral-850 font-snpro tracking-tight">Featured Posts</h2>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <%= for post <- @featured_posts do %>
              <div class="featured-card bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow p-6">
                <div class="flex items-center justify-between mb-2">
                  <%= if post.category do %>
                    <span class="text-xs font-medium text-orange-600"><%= post.category.name %></span>
                  <% end %>
                  <span class="text-xs text-gray-500">Featured</span>
                </div>
                <h3 class="text-xl font-bold mb-2 font-snpro tracking-tight">
                  <.link patch={"/post/" <> post.slug} class="hover:text-orange-600 transition-colors">
                    <%= post.title %>
                  </.link>
                </h3>
                <div class="text-sm text-gray-600 mb-3">
                  <%= Calendar.strftime(post.publishedDate, "%B %d, %Y") %>
                  <%= if post.series do %>
                    • Part of "<%= post.series.title %>"
                  <% end %>
                </div>
                <%= if post.meta_description do %>
                  <p class="text-gray-700 text-sm line-clamp-3"><%= post.meta_description %></p>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>

      <!-- Popular Series Section -->
      <%= if @popular_series != [] do %>
        <div class="popular-series mb-16">
          <div class="flex items-center justify-between mb-8">
            <h2 class="text-3xl font-bold text-neutral-850 font-snpro tracking-tight">Popular Series</h2>
            <.link patch="/series" class="text-sm text-orange-600 hover:text-orange-700 font-medium">
              View all series →
            </.link>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <%= for series <- @popular_series do %>
              <div class="series-card bg-gradient-to-br from-orange-50 to-yellow-50 rounded-lg p-6 hover:shadow-md transition-shadow">
                <h3 class="text-lg font-bold mb-2 font-snpro">
                  <.link patch={"/series/" <> series.slug} class="hover:text-orange-600">
                    <%= series.title %>
                  </.link>
                </h3>
                <p class="text-sm text-gray-700 mb-3"><%= series.description %></p>
                <div class="text-xs text-gray-600">
                  <%= length(series.posts) %> posts • 
                  <%= calculate_series_reading_time(series.posts) %> min total
                </div>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>

      <!-- All Posts -->
      <div class="posts">
        <h2 class="text-3xl font-bold mb-8 text-neutral-850 font-snpro tracking-tight">Recent Posts</h2>
        <ul>
        <%= for post <- @posts do %>
          <li class="mt-14">
            <div class="flex items-center gap-3 mb-2">
              <%= if post.category do %>
                <.link patch={"/category/" <> post.category.slug} class="text-sm font-medium text-orange-600 hover:text-orange-700">
                  <%= post.category.name %>
                </.link>
                <span class="text-gray-400">•</span>
              <% end %>
              <span class="text-sm text-gray-600"><%= estimate_reading_time(post.body) %> min read</span>
              <%= if post.series do %>
                <span class="text-gray-400">•</span>
                <span class="text-sm text-gray-600">Part of "<%= post.series.title %>"</span>
              <% end %>
            </div>
            <h3 class="text-neutral-850 text-4xl font-snpro mb-4 tracking-tighter">
              <.link patch={"/post/" <> post.slug} class="hover:text-neutral-500">
                <%= post.title %>
              </.link>
            </h3>
            <%= if post.tags != [] do %>
              <div class="mb-4">
                <%= for tag <- post.tags do %>
                  <.link patch={"/tag/" <> tag.slug} class="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2 hover:bg-gray-300">
                    #<%= tag.name %>
                  </.link>
                <% end %>
              </div>
            <% end %>
            <div class="text-gray-500 text-sm mb-4">
              <%= Calendar.strftime(post.publishedDate, "%B %d, %Y") %>
            </div>
            <div class="prose prose-xl prose-neutral max-w-none font-snpro post-body"><%= raw post.body %></div>
          </li>
        <% end %>
        </ul>
        
        <!-- Pagination Controls -->
        <.pagination 
          page={@page} 
          total_pages={@total_pages} 
          total_items={@total_posts} 
          base_url="/" 
        />
      </div>
      """
    end
    
    defp estimate_reading_time(content) do
      # Strip HTML tags and get plain text
      plain_text = content 
        |> String.replace(~r/<[^>]*>/, " ")
        |> String.replace(~r/\s+/, " ")
      
      # Rough estimate: 200 words per minute
      word_count = plain_text |> String.split() |> length()
      max(1, div(word_count, 200))
    end
    
    defp calculate_series_reading_time(posts) do
      posts
      |> Enum.map(&estimate_reading_time(&1.body))
      |> Enum.sum()
    end

end
