defmodule BlogWeb.ShowPost do
    use BlogWeb, :live_view

    require Logger
    use Timex

    alias Blog.Landing

    def mount(params, _session, socket) do
      %{"slug" => slug} = params
      post = Landing.get_post_by_slug(slug)
      tags = Landing.all_tags()
      {:ok, assign(socket, post: post, tags: tags, active_nav: :writing, page_title: post.title)}
    end

    def render(assigns) do
      ~H"""
      <div class="post">
        <h1 class="text-neutral-850 text-4xl font-snpro mt-20 mb-5 tracking-tighter">
          <%= @post.title %>
        </h1>
        <p class="text-neutral-500 mb-5"> <%= Timex.format!(@post.publishedDate, "{D} {Mfull} {YYYY}") %> </p>
        <div class="text-neutral-950 tracking-tight text-xl font-snpro post-body"><%= raw @post.body %></div>
        <div id="post-bottom-border" class="mt-24 border-2 border-chiffon-200"></div>
      </div>
      """
    end

end
