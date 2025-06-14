defmodule BlogWeb.CategoryShow do
  use BlogWeb, :live_view
  alias Blog.Landing
  import BlogWeb.LiveHelpers
  
  def mount(%{"slug" => slug}, _session, socket) do
    case Landing.get_category_by_slug(slug) do
      nil ->
        {:ok, push_navigate(socket, to: "/")}
        
      category ->
        socket =
          socket
          |> assign_sidebar_data()
          |> assign(
            category: category,
            active_nav: :writing,
            page_title: category.name,
            current_category: category,
            breadcrumbs: build_breadcrumbs(category)
          )
        
        {:ok, socket}
    end
  end
  
  def render(assigns) do
    ~H"""
    <div class="category-show">
      <!-- Breadcrumb Navigation -->
      <nav class="mb-8">
        <ul class="flex items-center gap-2 text-sm">
          <li>
            <.link navigate="/" class="text-orange-600 hover:text-orange-700">
              Home
            </.link>
          </li>
          <%= for {name, slug} <- @breadcrumbs do %>
            <li class="flex items-center gap-2">
              <span class="text-gray-400">/</span>
              <.link navigate={"/category/" <> slug} class="text-orange-600 hover:text-orange-700">
                <%= name %>
              </.link>
            </li>
          <% end %>
        </ul>
      </nav>
      
      <!-- Category Header -->
      <div class="mb-12">
        <h1 class="text-5xl font-bold mb-4 text-neutral-850 font-snpro tracking-tight">
          <%= @category.name %>
        </h1>
        <%= if @category.description do %>
          <p class="text-xl text-gray-600"><%= @category.description %></p>
        <% end %>
        
        <div class="mt-6 flex items-center gap-4 text-sm text-gray-600">
          <span class="flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <%= length(@category.posts) %> posts
          </span>
          
          <%= if @category.children != [] do %>
            <span class="flex items-center gap-2">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" />
              </svg>
              <%= length(@category.children) %> subcategories
            </span>
          <% end %>
        </div>
      </div>
      
      <!-- Subcategories -->
      <%= if @category.children != [] do %>
        <div class="mb-12">
          <h2 class="text-2xl font-bold mb-6 text-neutral-850 font-snpro">Subcategories</h2>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <%= for child <- @category.children do %>
              <.link 
                navigate={"/category/" <> child.slug}
                class="block p-4 bg-white rounded-lg shadow hover:shadow-md transition-shadow"
              >
                <h3 class="font-bold text-lg mb-2"><%= child.name %></h3>
                <%= if child.description do %>
                  <p class="text-sm text-gray-600 line-clamp-2"><%= child.description %></p>
                <% end %>
                <p class="text-sm text-gray-500 mt-2"><%= length(child.posts) %> posts</p>
              </.link>
            <% end %>
          </div>
        </div>
      <% end %>
      
      <!-- Posts in Category -->
      <div class="posts">
        <h2 class="text-2xl font-bold mb-8 text-neutral-850 font-snpro">
          Posts in <%= @category.name %>
        </h2>
        
        <%= if @category.posts == [] do %>
          <div class="text-center py-16">
            <svg class="w-16 h-16 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <h3 class="text-xl font-medium text-gray-600 mb-2">No posts yet</h3>
            <p class="text-gray-500">Check back later for posts in this category.</p>
          </div>
        <% else %>
          <ul class="space-y-12">
            <%= for post <- Enum.sort_by(@category.posts, & &1.publishedDate, {:desc, Date}) do %>
              <li>
                <article>
                  <div class="flex items-center gap-3 mb-2">
                    <span class="text-sm text-gray-600">
                      <%= Calendar.strftime(post.publishedDate, "%B %d, %Y") %>
                    </span>
                    <span class="text-gray-400">•</span>
                    <span class="text-sm text-gray-600"><%= estimate_reading_time(post.body) %> min read</span>
                    <%= if post.series do %>
                      <span class="text-gray-400">•</span>
                      <.link navigate={"/series/" <> post.series.slug} class="text-sm text-orange-600 hover:text-orange-700">
                        Part of "<%= post.series.title %>"
                      </.link>
                    <% end %>
                  </div>
                  
                  <h3 class="text-neutral-850 text-3xl font-snpro mb-4 tracking-tighter">
                    <.link navigate={"/post/" <> post.slug} class="hover:text-neutral-500">
                      <%= post.title %>
                    </.link>
                  </h3>
                  
                  <%= if post.meta_description do %>
                    <p class="text-gray-700 mb-4 text-lg"><%= post.meta_description %></p>
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
                </article>
              </li>
            <% end %>
          </ul>
        <% end %>
      </div>
    </div>
    """
  end
  
  defp build_breadcrumbs(category) do
    build_breadcrumbs(category, [])
  end
  
  defp build_breadcrumbs(nil, acc), do: Enum.reverse(acc)
  defp build_breadcrumbs(category, acc) do
    new_acc = [{category.name, category.slug} | acc]
    build_breadcrumbs(category.parent, new_acc)
  end
  
  defp estimate_reading_time(content) do
    plain_text = content 
      |> String.replace(~r/<[^>]*>/, " ")
      |> String.replace(~r/\s+/, " ")
    
    word_count = plain_text |> String.split() |> length()
    max(1, div(word_count, 200))
  end
end