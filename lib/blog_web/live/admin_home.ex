defmodule BlogWeb.AdminHome do
    use BlogWeb, :admin_live_view
    require Logger
    alias Blog.{Admin, Landing, Repo}
    import Ecto.Query

    def mount(_params, _session, socket) do
      # Get stats for dashboard
      total_posts = Repo.aggregate(Blog.Post, :count)
      total_drafts = Repo.aggregate(Blog.Admin.Draft, :count)
      total_tags = Repo.aggregate(Blog.Admin.Tag, :count)
      
      # Get recent posts
      recent_posts = Landing.all_posts() |> Enum.take(5)
      
      # Get recent drafts
      recent_drafts = Admin.all_drafts() |> Enum.take(5)
      
      {:ok, assign(socket,
        active_admin_nav: :dashboard,
        page_title: "Dashboard",
        total_posts: total_posts,
        total_drafts: total_drafts,
        total_tags: total_tags,
        recent_posts: recent_posts,
        recent_drafts: recent_drafts
      )}
    end

    def render(assigns) do
        ~H"""
        <!-- Page Header -->
        <div class="mb-8">
          <h1 class="text-3xl font-bold text-neutral-850">Dashboard</h1>
          <p class="mt-2 text-neutral-600">Welcome back! Here's what's happening with your blog.</p>
        </div>

        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <!-- Published Posts -->
          <div class="bg-white rounded-lg shadow p-6 border-2 border-chiffon-200">
            <div class="flex items-center">
              <div class="flex-shrink-0 bg-lava rounded-md p-3">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <div class="ml-5">
                <p class="text-neutral-600 text-sm font-medium">Published Posts</p>
                <p class="text-2xl font-semibold text-neutral-850"><%= @total_posts %></p>
              </div>
            </div>
          </div>

          <!-- Drafts -->
          <div class="bg-white rounded-lg shadow p-6 border-2 border-chiffon-200">
            <div class="flex items-center">
              <div class="flex-shrink-0 bg-tangerine-500 rounded-md p-3">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
              </div>
              <div class="ml-5">
                <p class="text-neutral-600 text-sm font-medium">Drafts</p>
                <p class="text-2xl font-semibold text-neutral-850"><%= @total_drafts %></p>
              </div>
            </div>
          </div>

          <!-- Tags -->
          <div class="bg-white rounded-lg shadow p-6 border-2 border-chiffon-200">
            <div class="flex items-center">
              <div class="flex-shrink-0 bg-sacramento-500 rounded-md p-3">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                </svg>
              </div>
              <div class="ml-5">
                <p class="text-neutral-600 text-sm font-medium">Tags</p>
                <p class="text-2xl font-semibold text-neutral-850"><%= @total_tags %></p>
              </div>
            </div>
          </div>
        </div>

        <!-- Recent Content -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <!-- Recent Posts -->
          <div class="bg-white rounded-lg shadow border-2 border-chiffon-200">
            <div class="px-6 py-4 border-b border-chiffon-200">
              <div class="flex items-center justify-between">
                <h2 class="text-lg font-semibold text-neutral-850">Recent Posts</h2>
                <.link navigate="/admin/posts" class="text-sm text-lava hover:text-orange-700">
                  View all →
                </.link>
              </div>
            </div>
            <div class="p-6">
              <%= if @recent_posts == [] do %>
                <p class="text-neutral-500 text-center py-4">No posts yet. Start writing!</p>
              <% else %>
                <ul class="space-y-4">
                  <%= for post <- @recent_posts do %>
                    <li class="flex items-center justify-between">
                      <div class="flex-1 min-w-0">
                        <.link navigate={"/post/#{post.slug}"} class="text-neutral-850 hover:text-lava font-medium truncate block">
                          <%= post.title %>
                        </.link>
                        <p class="text-sm text-neutral-500">
                          <%= Calendar.strftime(post.publishedDate, "%B %d, %Y") %>
                        </p>
                      </div>
                      <.link navigate={"/admin/post/#{post.id}/edit"} class="ml-4 text-neutral-400 hover:text-neutral-600">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                      </.link>
                    </li>
                  <% end %>
                </ul>
              <% end %>
            </div>
          </div>

          <!-- Recent Drafts -->
          <div class="bg-white rounded-lg shadow border-2 border-chiffon-200">
            <div class="px-6 py-4 border-b border-chiffon-200">
              <div class="flex items-center justify-between">
                <h2 class="text-lg font-semibold text-neutral-850">Recent Drafts</h2>
                <.link navigate="/admin/drafts" class="text-sm text-lava hover:text-orange-700">
                  View all →
                </.link>
              </div>
            </div>
            <div class="p-6">
              <%= if @recent_drafts == [] do %>
                <p class="text-neutral-500 text-center py-4">No drafts yet.</p>
              <% else %>
                <ul class="space-y-4">
                  <%= for draft <- @recent_drafts do %>
                    <li class="flex items-center justify-between">
                      <div class="flex-1 min-w-0">
                        <.link navigate={"/admin/draft/#{draft.id}/edit"} class="text-neutral-850 hover:text-lava font-medium truncate block">
                          <%= draft.title || "Untitled Draft" %>
                        </.link>
                        <p class="text-sm text-neutral-500">
                          Last modified <%= Calendar.strftime(draft.updated_at, "%B %d, %Y") %>
                        </p>
                      </div>
                      <div class="ml-4 flex items-center space-x-2">
                        <.link navigate={"/admin/draft/#{draft.id}/edit"} class="text-neutral-400 hover:text-neutral-600">
                          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                          </svg>
                        </.link>
                      </div>
                    </li>
                  <% end %>
                </ul>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="mt-8 bg-white rounded-lg shadow p-6 border-2 border-chiffon-200">
          <h2 class="text-lg font-semibold text-neutral-850 mb-4">Quick Actions</h2>
          <div class="flex flex-wrap gap-4">
            <.link
              navigate="/admin/draft"
              class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-lava hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500"
            >
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
              </svg>
              New Post
            </.link>
            
            <.link
              navigate="/admin/tags"
              class="inline-flex items-center px-4 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-chiffon-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-lava"
            >
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
              </svg>
              Manage Tags
            </.link>
            
            <.link
              navigate="/"
              class="inline-flex items-center px-4 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-chiffon-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-lava"
            >
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
              </svg>
              View Site
            </.link>
          </div>
        </div>
        """
    end

    def handle_event("view_draft", _unsigned_params, socket) do
      drafts = Admin.all_drafts()  # Fetch all drafts
      {:noreply, assign(socket, drafts: drafts)}
    end

end
