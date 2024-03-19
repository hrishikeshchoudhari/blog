defmodule BlogWeb.Home do
    use BlogWeb, :live_view
    require Logger
    alias Blog.Landing

    def mount(_params, _session, socket) do
      posts = Landing.all_posts()
      {:ok, assign(socket, posts: posts)}
    end

    def render(assigns) do
      ~H"""
      <div class="posts">
        <h2>Posts</h2>
        <ul>
        <%= for post <- @posts do %>
          <li class="mt-14 ">
            <h3 class="text-slate-700 text-4xl font-calistoga mb-5"><%= post.title %></h3>
            <div class="text-slate-900 tracking-tight text-xl font-snpro font-medium "><%= raw post.body %></div>
          </li>
        <% end %>
        </ul>
      </div>
      """
    end
end