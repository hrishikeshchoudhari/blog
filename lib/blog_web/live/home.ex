defmodule BlogWeb.Home do
    use BlogWeb, :live_view
    require Logger
    alias Blog.Landing


    def mount(_params, _session, socket) do
      posts = Landing.all_posts()
      tag = "tag"

      {:ok, assign(socket, posts: posts, tag: tag, active_nav: :writing, page_title: "All Posts")}
    end

    def render(assigns) do
      ~H"""
      <div class="posts">
        <ul>
        <%= for post <- @posts do %>
          <li class="mt-14 ">
            <h3 class="text-neutral-850 text-4xl font-snpro mb-10 tracking-tighter">
              <.link patch={"/" <> @tag <> "/" <> post.slug } class="hover:text-neutral-500">
                <%= post.title %>
              </.link>
            </h3>
            <div class="text-neutral-950 tracking-tight text-xl font-snpro post-body"><%= raw post.body %></div>
          </li>
        <% end %>
        </ul>
      </div>
      """
    end

end
