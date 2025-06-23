defmodule BlogWeb.AdminPosts do
  use BlogWeb, :admin_live_view
  alias Blog.{Admin, Landing, Repo, Post}
  import Ecto.Query
  import BlogWeb.Components.Pagination

  def mount(params, _session, socket) do
    page = String.to_integer(params["page"] || "1")
    type_filter = params["type"] || "all"
    
    paginated_data = Admin.list_all_posts(page, 20, %{type: type_filter})
    
    {:ok, assign(socket,
      active_admin_nav: :posts,
      page_title: "Manage Content",
      posts: paginated_data.posts,
      filtered_posts: paginated_data.posts,
      selected_type: type_filter,
      page: paginated_data.page,
      total_pages: paginated_data.total_pages,
      total_posts: paginated_data.total_posts
    )}
  end
  
  def handle_params(params, _uri, socket) do
    page = String.to_integer(params["page"] || "1")
    type_filter = params["type"] || socket.assigns.selected_type || "all"
    
    paginated_data = Admin.list_all_posts(page, 20, %{type: type_filter})
    
    {:noreply, 
      socket
      |> assign(
        posts: paginated_data.posts,
        filtered_posts: paginated_data.posts,
        selected_type: type_filter,
        page: paginated_data.page,
        total_pages: paginated_data.total_pages,
        total_posts: paginated_data.total_posts
      )
    }
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8 flex justify-between items-center">
        <div>
          <h1 class="text-3xl font-bold text-neutral-850">Published Content</h1>
          <p class="mt-2 text-neutral-600">Manage all your published posts, projects, and readings</p>
        </div>
        <.link
          navigate="/admin/draft"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-lava hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500"
        >
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          New Content
        </.link>
      </div>

      <!-- Content Type Filter -->
      <div class="mb-6 flex gap-2">
        <button
          phx-click="filter-type"
          phx-value-type="all"
          class={"px-4 py-2 rounded-md text-sm font-medium " <> 
                 if(@selected_type == "all", do: "bg-sacramento-600 text-white", else: "bg-white text-neutral-700 border border-neutral-300 hover:bg-neutral-50")}
        >
          All
        </button>
        <button
          phx-click="filter-type"
          phx-value-type="post"
          class={"px-4 py-2 rounded-md text-sm font-medium " <> 
                 if(@selected_type == "post", do: "bg-sacramento-600 text-white", else: "bg-white text-neutral-700 border border-neutral-300 hover:bg-neutral-50")}
        >
          Blog Posts
        </button>
        <button
          phx-click="filter-type"
          phx-value-type="project"
          class={"px-4 py-2 rounded-md text-sm font-medium " <> 
                 if(@selected_type == "project", do: "bg-sacramento-600 text-white", else: "bg-white text-neutral-700 border border-neutral-300 hover:bg-neutral-50")}
        >
          Projects
        </button>
        <button
          phx-click="filter-type"
          phx-value-type="reading"
          class={"px-4 py-2 rounded-md text-sm font-medium " <> 
                 if(@selected_type == "reading", do: "bg-sacramento-600 text-white", else: "bg-white text-neutral-700 border border-neutral-300 hover:bg-neutral-50")}
        >
          Readings
        </button>
      </div>

      <!-- Posts List -->
      <div class="bg-white rounded-lg shadow-sm border-2 border-chiffon-200">
        <div class="px-6 py-4 border-b border-chiffon-200">
          <h2 class="text-lg font-semibold text-neutral-850">
            <%= case @selected_type do %>
              <% "all" -> %>All Content
              <% "post" -> %>Blog Posts
              <% "project" -> %>Projects
              <% "reading" -> %>Book Reviews
            <% end %>
            (<%= length(@filtered_posts) %>)
          </h2>
        </div>
        <div class="overflow-hidden">
          <%= if @posts == [] do %>
            <p class="text-neutral-500 text-center py-12">No posts yet. Start by creating your first post!</p>
          <% else %>
            <table class="min-w-full divide-y divide-neutral-200">
              <thead class="bg-chiffon-50">
                <tr>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-neutral-500 uppercase tracking-wider">
                    Title
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-neutral-500 uppercase tracking-wider">
                    Type
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-neutral-500 uppercase tracking-wider">
                    Tags
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-neutral-500 uppercase tracking-wider">
                    Published
                  </th>
                  <th scope="col" class="relative px-6 py-3">
                    <span class="sr-only">Actions</span>
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-neutral-200">
                <%= for post <- @filtered_posts do %>
                  <tr class="hover:bg-chiffon-50">
                    <td class="px-6 py-4">
                      <div>
                        <.link navigate={get_post_url(post)} class="text-neutral-850 font-medium hover:text-lava">
                          <%= post.title %>
                        </.link>
                        <p class="text-sm text-neutral-500">/<%= post.slug %></p>
                      </div>
                    </td>
                    <td class="px-6 py-4">
                      <span class={"inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium " <> get_type_badge_class(post.post_type)}>
                        <%= format_post_type(post.post_type) %>
                      </span>
                    </td>
                    <td class="px-6 py-4">
                      <div class="flex flex-wrap gap-1">
                        <%= for tag <- post.tags do %>
                          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-chiffon-100 text-neutral-800">
                            <%= tag.name %>
                          </span>
                        <% end %>
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-neutral-500">
                      <%= Calendar.strftime(post.publishedDate, "%B %d, %Y") %>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <div class="flex justify-end space-x-2">
                        <.link navigate={get_post_url(post)} class="text-neutral-400 hover:text-neutral-600">
                          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                          </svg>
                        </.link>
                        <.link navigate={"/admin/post/#{post.id}/edit"} class="text-neutral-400 hover:text-neutral-600">
                          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                          </svg>
                        </.link>
                        <button class="text-neutral-400 hover:text-salmon-600">
                          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                          </svg>
                        </button>
                      </div>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          <% end %>
        </div>
        
        <!-- Pagination Controls -->
        <.pagination 
          page={@page} 
          total_pages={@total_pages} 
          total_items={@total_posts} 
          base_url={"/admin/posts" <> if(@selected_type != "all", do: "?type=#{@selected_type}", else: "")} 
          item_name="items"
        />
      </div>
    </div>
    """
  end
  
  def handle_event("filter-type", %{"type" => type}, socket) do
    # Navigate to the new URL with the type filter
    path = if type == "all" do
      "/admin/posts"
    else
      "/admin/posts?type=#{type}"
    end
    
    {:noreply, push_patch(socket, to: path)}
  end
  
  defp get_post_url(post) do
    case post.post_type do
      "project" -> "/project/" <> post.slug
      "reading" -> "/reading/" <> post.slug
      _ -> "/post/" <> post.slug
    end
  end
  
  defp format_post_type("post"), do: "Blog Post"
  defp format_post_type("project"), do: "Project"
  defp format_post_type("reading"), do: "Reading"
  defp format_post_type(_), do: "Unknown"
  
  defp get_type_badge_class("post"), do: "bg-blue-100 text-blue-800"
  defp get_type_badge_class("project"), do: "bg-purple-100 text-purple-800"
  defp get_type_badge_class("reading"), do: "bg-green-100 text-green-800"
  defp get_type_badge_class(_), do: "bg-gray-100 text-gray-800"
end