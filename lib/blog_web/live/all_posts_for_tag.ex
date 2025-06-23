defmodule BlogWeb.AllPostsForTag do
    use BlogWeb, :live_view

    require Logger
    alias Blog.Landing
    alias Blog.Admin.Tag
    import BlogWeb.LiveHelpers
    import BlogWeb.Components.Pagination

    def mount(params, _session, socket) do
      %{"tagslug" => tag_slug} = params
      page = String.to_integer(params["page"] || "1")
      
      paginated_data = Landing.list_posts_by_tag_slug(tag_slug, page, 10)
      
      page_title = if paginated_data.tag, do: "Posts tagged '#{paginated_data.tag.name}'", else: "Tag not found"
      
      {:ok, 
        socket
        |> assign_sidebar_data()
        |> assign(
          posts: paginated_data.posts,
          tag: paginated_data.tag,
          tag_slug: tag_slug,
          page: paginated_data.page,
          total_pages: paginated_data.total_pages,
          total_posts: paginated_data.total_posts,
          active_nav: :writing, 
          page_title: page_title,
          feed_url: "/tag/#{tag_slug}/feed.xml",
          feed_title: if(paginated_data.tag, do: "Posts tagged '#{paginated_data.tag.name}' - Blog Feed", else: "Tag Feed")
        )
      }
    end
    
    def handle_params(params, _uri, socket) do
      %{"tagslug" => tag_slug} = params
      page = String.to_integer(params["page"] || "1")
      
      paginated_data = Landing.list_posts_by_tag_slug(tag_slug, page, 10)
      
      {:noreply, 
        socket
        |> assign(
          posts: paginated_data.posts,
          page: paginated_data.page,
          total_pages: paginated_data.total_pages,
          total_posts: paginated_data.total_posts
        )
      }
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
            
            <!-- Pagination Controls -->
            <.pagination 
              page={@page} 
              total_pages={@total_pages} 
              total_items={@total_posts} 
              base_url={"/tag/#{@tag_slug}"} 
            />
          <% end %>
        <% else %>
          <h1 class="text-3xl font-bold mb-8">Tag not found</h1>
          <p class="text-gray-500">The tag '<%= @tag_slug %>' does not exist.</p>
        <% end %>
      </div>
      """
    end

end
