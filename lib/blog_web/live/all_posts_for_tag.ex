defmodule BlogWeb.AllPostsForTag do
    use BlogWeb, :live_view

    require Logger
    use Timex

    alias Blog.Landing

    def mount(params, _session, socket) do
      %{"tagslug" => slug} = params
      # post = Landing.get_post_by_slug(slug)
      tags = Landing.all_tags()
      {:ok, assign(socket, tags: tags, active_nav: :writing, s: slug)}
    end

    def render(assigns) do
      ~H"""
      <h1>All posts for this tag <%= assigns.s %>  </h1>
      """
    end

end
