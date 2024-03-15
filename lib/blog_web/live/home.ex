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
          <li>
            <h3 class="text-cyan-400"><%= post.title %></h3>
            <p class="text-cyan-700"><%= raw post.body %></p>
          </li>
        <% end %>
        </ul>
      </div>
      """
    end
end