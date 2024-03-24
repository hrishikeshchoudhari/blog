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
      <div id="header-section">
        <h1 class="mt-10 text-black text-4xl font-snpro mb-10 text-center font-medium">
        Professionally experienced in Product Management and Cloud Systems Architecture. Managed teams of 25+ members distributed globally.
        </h1>
        <ul>
        <li class="mb-1">
          <div class="flex flex-row">
              <div class="text-3xl w-36 text-teal-500 font-snpro font-medium tracking-tight">Code</div>
              <div class="flex-col h-5 w-full pl-1">
                <div class="w-full h-1 bg-gradient-to-r from-teal-500 to-teal-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-teal-500 to-teal-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-teal-500 to-teal-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-teal-500 to-teal-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-teal-500 to-teal-950 mb-1 rounded-l-lg"></div>
              </div>
            </div>
          </li>
          <li class="mb-1">
            <div class="flex flex-row">
              <div class="text-3xl w-36 text-amber-600 font-snpro font-medium tracking-tight">People</div>
              <div class="flex-col h-5 w-full pl-1">
                <div class="w-full h-1 bg-gradient-to-r from-amber-600 to-amber-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-amber-600 to-amber-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-amber-600 to-amber-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-amber-600 to-amber-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-amber-600 to-amber-950 mb-1 rounded-l-lg"></div>
              </div>
            </div>
          </li>

          <li class="mb-1">
          <div class="flex flex-row">
              <div class="text-3xl w-36 text-purple-600 font-snpro font-medium tracking-tight">Design</div>
              <div class="flex-col h-5 w-full pl-1">
                <div class="w-full h-1 bg-gradient-to-r from-purple-600 to-purple-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-purple-600 to-purple-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-purple-600 to-purple-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-purple-600 to-purple-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-purple-600 to-purple-950 mb-1 rounded-l-lg"></div>
              </div>
            </div>
          </li>
          <li class="mb-16">
          <div class="flex flex-row">
              <div class="text-3xl w-36 text-sky-600 font-snpro font-medium tracking-tight">Process</div>
              <div class="flex-col h-5 w-full pl-1">
                <div class="w-full h-1 bg-gradient-to-r from-sky-600 to-sky-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-sky-600 to-sky-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-sky-600 to-sky-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-sky-600 to-sky-950 mb-1 rounded-l-lg"></div>
                <div class="w-full h-1 bg-gradient-to-r from-sky-600 to-sky-950 mb-1 rounded-l-lg"></div>
              </div>
            </div>
          </li>
        </ul>
      </div>

      <div class="posts">
        <ul>
        <%= for post <- @posts do %>
          <li class="mt-14 ">
            <h3 class="text-slate-700 text-4xl font-snpro mb-3 tracking-tighter"><%= post.title %></h3>
            <div class="text-slate-900 tracking-tight text-xl font-snpro font-medium "><%= raw post.body %></div>
          </li>
        <% end %>
        </ul>
      </div>
      """
    end
end