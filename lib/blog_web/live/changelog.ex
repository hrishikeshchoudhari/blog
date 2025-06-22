defmodule BlogWeb.Changelog do
  use BlogWeb, :live_view
  alias Blog.Landing
  import BlogWeb.LiveHelpers

  def mount(_params, _session, socket) do
    {:ok, 
      socket
      |> assign_sidebar_data()
      |> assign(active_nav: :changelog, page_title: "Changelog")
    }
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
            <h2 class="text-2xl font-bold">v3.1.0</h2>
            <span class="text-sm bg-green-100 text-green-800 px-2 py-1 rounded">Latest</span>
            <span class="text-gray-500 text-sm"><%= Calendar.strftime(DateTime.utc_now(), "%B %d, %Y") %></span>
          </div>
          <ul class="space-y-2 text-gray-700">
            <li class="flex gap-2">
              <span class="text-green-500">✓</span>
              <strong>Multi-Content-Type System:</strong> Support for blog posts, projects, and book reviews with type-specific fields
            </li>
            <li class="flex gap-2">
              <span class="text-green-500">✓</span>
              <strong>Project Showcase:</strong> Dedicated project pages with tech stack display, demo links, and GitHub integration
            </li>
            <li class="flex gap-2">
              <span class="text-green-500">✓</span>
              <strong>Reading List:</strong> Book review system with ratings, author info, ISBN tracking, and date read
            </li>
            <li class="flex gap-2">
              <span class="text-green-500">✓</span>
              <strong>Dynamic Content Forms:</strong> Type-specific fields appear dynamically based on content type selection
            </li>
            <li class="flex gap-2">
              <span class="text-green-500">✓</span>
              <strong>Smart URL Routing:</strong> Automatic URL prefixes (/post/, /project/, /reading/) based on content type
            </li>
            <li class="flex gap-2">
              <span class="text-green-500">✓</span>
              <strong>Enhanced Admin:</strong> Unified content management with type filtering and proper edit links
            </li>
            <li class="flex gap-2">
              <span class="text-green-500">✓</span>
              <strong>Type-Specific Templates:</strong> Custom display layouts for projects (with tech badges) and readings (with star ratings)
            </li>
          </ul>
        </div>

        <!-- Previous Version -->
        <div class="border-l-4 border-gray-300 pl-6">
          <div class="flex items-baseline gap-3 mb-2">
            <h2 class="text-2xl font-bold">v3.0.0</h2>
            <span class="text-gray-500 text-sm">June 14, 2025</span>
          </div>
          <ul class="space-y-2 text-gray-700">
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              RSS/Atom Feed System with main, category, series, and tag-specific feeds
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Content Organization with hierarchical categories and series
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Media Management with upload system and gallery view
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Enhanced Editor with Tailwind Typography integration
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Single-user blog mode with registration prevention
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              SEO Improvements with meta tags and sitemap generation
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Feed Discovery with auto-discovery links and OPML export
            </li>
          </ul>
        </div>

        <!-- Previous Version -->
        <div class="border-l-4 border-gray-300 pl-6">
          <div class="flex items-baseline gap-3 mb-2">
            <h2 class="text-2xl font-bold">v2.0.0</h2>
            <span class="text-gray-500 text-sm">June 11, 2024</span>
          </div>
          <ul class="space-y-2 text-gray-700">
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Complete tag system implementation with many-to-many relationships
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Docker containerization for development environment
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Improved sidebar design with active tag highlighting
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
              Sticky footer implementation
            </li>
            <li class="flex gap-2">
              <span class="text-gray-400">•</span>
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

      <!-- Technical Details -->
      <div class="mt-12 p-6 bg-gray-50 rounded-lg">
        <h2 class="text-xl font-bold mb-3 text-gray-900">Recent Technical Improvements</h2>
        <div class="space-y-3 text-gray-700">
          <div>
            <h3 class="font-semibold text-gray-800">🎯 Multi-Content-Type Architecture</h3>
            <p class="text-sm">Polymorphic content system with post_type field enabling blog posts, projects, and readings. Type-specific fields stored in same table with smart validation based on content type. Automatic URL routing (/post/, /project/, /reading/) based on type.</p>
          </div>
          <div>
            <h3 class="font-semibold text-gray-800">📝 Dynamic Form System</h3>
            <p class="text-sm">Phoenix LiveView-powered forms that show/hide fields based on content type selection. Tech stack stored as PostgreSQL array with comma-separated input parsing. Rating validation only for reading type.</p>
          </div>
          <div>
            <h3 class="font-semibold text-gray-800">🔧 RSS/Atom Implementation</h3>
            <p class="text-sm">Using Atomex library with custom XML generator for feed compatibility. Includes validation fixes for iframe removal and proper entity encoding.</p>
          </div>
          <div>
            <h3 class="font-semibold text-gray-800">🔒 Registration Control</h3>
            <p class="text-sm">Environment-based registration control with single-user mode for production deployments on Hetzner.</p>
          </div>
          <div>
            <h3 class="font-semibold text-gray-800">📁 Content Organization</h3>
            <p class="text-sm">Hierarchical categories, post series with ordering, draft revisions, and enhanced SEO fields across all content types.</p>
          </div>
          <div>
            <h3 class="font-semibold text-gray-800">🖼️ Media Management</h3>
            <p class="text-sm">Centralized upload system with image gallery, automatic file organization, and integration with blog posts.</p>
          </div>
        </div>
      </div>

      <!-- Upcoming -->
      <div class="mt-12 p-6 bg-blue-50 rounded-lg">
        <h2 class="text-xl font-bold mb-3 text-blue-900">Upcoming Features</h2>
        <ul class="space-y-2 text-blue-800">
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Book API Integration (fetch book details from ISBN)
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Project screenshots gallery with lightbox
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Reading statistics and yearly book challenges
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            GitHub API integration for project stats
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Type-specific RSS feeds (/projects/feed.xml, /readings/feed.xml)
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Search functionality with type filtering
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Comments system with AI moderation
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Newsletter integration with content type preferences
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Analytics dashboard with content type insights
          </li>
          <li class="flex gap-2">
            <span class="text-blue-500">→</span>
            Dark mode toggle
          </li>
        </ul>
      </div>
    </div>
    """
  end
end