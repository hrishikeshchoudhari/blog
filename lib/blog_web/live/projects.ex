defmodule BlogWeb.Projects do
  use BlogWeb, :live_view
  alias Blog.Landing
  import BlogWeb.LiveHelpers

  def mount(_params, _session, socket) do
    {:ok, 
      socket
      |> assign_sidebar_data()
      |> assign(active_nav: :projects, page_title: "Projects")
    }
  end

  def render(assigns) do
    ~H"""
    <div class="projects">
      <h1 class="text-neutral-850 text-4xl font-snpro mt-20 mb-10 tracking-tighter">
        Projects
      </h1>
      
      <div class="grid gap-8 mb-12">
        <!-- Project 1 -->
        <div class="border-2 border-gray-200 rounded-lg p-6 hover:border-lava transition-colors">
          <h2 class="text-2xl font-bold mb-3">Phoenix Blog Platform</h2>
          <p class="text-gray-600 mb-4">
            A modern blog platform built with Elixir Phoenix LiveView, featuring real-time updates, 
            markdown editing, and a sophisticated tagging system.
          </p>
          <div class="flex gap-2 flex-wrap">
            <span class="text-sm bg-gray-100 px-3 py-1 rounded-full">Elixir</span>
            <span class="text-sm bg-gray-100 px-3 py-1 rounded-full">Phoenix LiveView</span>
            <span class="text-sm bg-gray-100 px-3 py-1 rounded-full">PostgreSQL</span>
            <span class="text-sm bg-gray-100 px-3 py-1 rounded-full">Docker</span>
          </div>
        </div>

        <!-- Project 2 -->
        <div class="border-2 border-gray-200 rounded-lg p-6 hover:border-lava transition-colors">
          <h2 class="text-2xl font-bold mb-3">Data Analytics Dashboard</h2>
          <p class="text-gray-600 mb-4">
            Real-time analytics dashboard for business metrics, built with modern data visualization 
            libraries and streaming data pipelines.
          </p>
          <div class="flex gap-2 flex-wrap">
            <span class="text-sm bg-gray-100 px-3 py-1 rounded-full">React</span>
            <span class="text-sm bg-gray-100 px-3 py-1 rounded-full">D3.js</span>
            <span class="text-sm bg-gray-100 px-3 py-1 rounded-full">WebSockets</span>
            <span class="text-sm bg-gray-100 px-3 py-1 rounded-full">AWS</span>
          </div>
        </div>

        <!-- Project 3 -->
        <div class="border-2 border-gray-200 rounded-lg p-6 hover:border-lava transition-colors">
          <h2 class="text-2xl font-bold mb-3">Open Source Contributions</h2>
          <p class="text-gray-600 mb-4">
            Active contributor to various open source projects, focusing on developer tools 
            and documentation improvements.
          </p>
          <div class="flex gap-2 flex-wrap">
            <span class="text-sm bg-gray-100 px-3 py-1 rounded-full">Open Source</span>
            <span class="text-sm bg-gray-100 px-3 py-1 rounded-full">Community</span>
            <span class="text-sm bg-gray-100 px-3 py-1 rounded-full">Documentation</span>
          </div>
        </div>
      </div>

      <p class="text-gray-500 text-center italic">
        More projects coming soon...
      </p>
    </div>
    """
  end
end