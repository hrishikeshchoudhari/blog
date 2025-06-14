defmodule BlogWeb.AllPostsForTag do
    use BlogWeb, :live_view

    require Logger
    alias Blog.Landing
    alias Blog.Admin.Tag

    def mount(params, _session, socket) do
      %{"tagslug" => tag_slug} = params
      posts = Landing.get_posts_by_tag_slug(tag_slug)
      tag = Blog.Repo.get_by(Tag, slug: tag_slug)
      all_tags = Landing.all_tags()  # Add this for the sidebar
      
      page_title = if tag, do: "Posts tagged '#{tag.name}'", else: "Tag not found"
      
      {:ok, assign(socket, 
        posts: posts, 
        tag: tag,
        tags: all_tags,  # Add this
        tag_slug: tag_slug,
        active_nav: :writing, 
        page_title: page_title,
        feed_url: "/tag/#{tag_slug}/feed.xml",
        feed_title: if(tag, do: "Posts tagged '#{tag.name}' - Blog Feed", else: "Tag Feed")
      )}
    end

    def render(assigns) do
      ~H"""
      <div class="posts">
        <%= if @tag do %>
          <h1 class="text-3xl font-bold mb-8">Posts tagged '<%= @tag.name %>'</h1>
          <%= if @posts == [] do %>
            <p class="text-gray-500">No posts found with this tag.</p>
          <% else %>
            <ul>
            <%= for post <- @posts do %>
              <li class="mt-14">
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
          <% end %>
        <% else %>
          <h1 class="text-3xl font-bold mb-8">Tag not found</h1>
          <p class="text-gray-500">The tag '<%= @tag_slug %>' does not exist.</p>
        <% end %>
      </div>
      """
    end

end
