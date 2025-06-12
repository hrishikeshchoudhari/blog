defmodule BlogWeb.Changelog do
  use BlogWeb, :live_view
  alias Blog.Landing

  def mount(_params, _session, socket) do
    tags = Landing.all_tags()
    {:ok, assign(socket, active_nav: :changelog, tags: tags, page_title: "Changelog")}
  end

  def render(assigns) do
    ~H"""
    <div class="changelog">
      <h1 class="text-neutral-850 text-4xl font-snpro mt-20 mb-10 tracking-tighter">
        Changelog
      </h1>
      
      <p class="text-lg mb-8 text-gray-600">
        A living document of updates, improvements, and milestones for this blog.
      </p>

      <!-- Version entries -->
      <div class="space-y-8">
        <!-- Latest Version -->
        <div class="border-l-4 border-green-500 pl-6">
          <div class="flex items-baseline gap-3 mb-2">
            <h2 class="text-2xl font-bold">v2.0.0</h2>
            <span class="text-sm bg-green-100 text-green-800 px-2 py-1 rounded">Latest</span>
            <span class="text-gray-500 text-sm">June 11, 2024</span>
          </div>
          <ul class="space-y-2 text-gray-700">
            <li class="flex gap-2">
              <span class="text-green-500">✓</span>
              Complete tag system implementation with many-to-many relationships
            </li>
            <li class="flex gap-2">
              <span class="text-green-500">✓</span>
              Docker containerization for development environment
            </li>
            <li class="flex gap-2">
              <span class="text-green-500">✓</span>
              Improved sidebar design with active tag highlighting
            </li>
            <li class="flex gap-2">
              <span class="text-green-500">✓</span>
              Sticky footer implementation
            </li>
            <li class="flex gap-2">
              <span class="text-green-500">✓</span>
              Migration from Fly.io to Hetzner deployment strategy
            </li>
          </ul>
        </div>

        <!-- Previous Version -->
        <div class="border-l-4 border-gray-300 pl-6">
          <div class="flex items-baseline gap-3 mb-2">
            <h2 class="text-2xl font-bold">v1.5.0</h2>
            <span class="text-gray-500 text-sm">March 15, 2024</span>
          </div>
          <ul class="space-y-2 text-gray-700">
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Added Monaco editor for markdown editing
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Implemented draft and publish workflow
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              User authentication system
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Basic tag creation functionality
            </li>
          </ul>
        </div>

        <!-- Initial Release -->
        <div class="border-l-4 border-gray-300 pl-6">
          <div class="flex items-baseline gap-3 mb-2">
            <h2 class="text-2xl font-bold">v1.0.0</h2>
            <span class="text-gray-500 text-sm">March 9, 2024</span>
          </div>
          <ul class="space-y-2 text-gray-700">
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Initial blog setup with Phoenix LiveView
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Basic post creation and display
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Custom Tailwind styling with SNPro and Calistoga fonts
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Responsive design implementation
            </li>
          </ul>
        </div>
      </div>

      <!-- Upcoming -->
      <div class="mt-12 p-6 bg-blue-50 rounded-lg">
        <h2 class="text-xl font-bold mb-3 text-blue-900">Upcoming Features</h2>
        <ul class="space-y-2 text-blue-800">
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            RSS feed generation
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Search functionality
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Comments system
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Newsletter integration
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Analytics dashboard
          </li>
        </ul>
      </div>
    </div>
    """
  end
end