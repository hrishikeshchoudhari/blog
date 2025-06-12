defmodule BlogWeb.Home do
    use BlogWeb, :live_view
    require Logger
    alias Blog.Landing


    def mount(_params, _session, socket) do
      posts = Landing.all_posts()
      tags = Landing.all_tags()

      {:ok, assign(socket, posts: posts, tags: tags, active_nav: :writing, page_title: "All Posts")}
    end

    def render(assigns) do
      ~H"""
      <div class="posts">
        <ul>
        <%= for post <- @posts do %>
          <li class="mt-14 ">
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
      </div>
      """
    end

end
