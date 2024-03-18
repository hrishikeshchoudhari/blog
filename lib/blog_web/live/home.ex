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
            <h3 class="text-sacramento-700 text-4xl font-serif mb-5 "><%= post.title %></h3>
            <p class="text-sacramento-900 text-lg font-sans "><%= raw post.body %></p>
          </li>
        <% end %>
        </ul>
      </div>
      """
    end
end