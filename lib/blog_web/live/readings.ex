defmodule BlogWeb.Readings do
  use BlogWeb, :live_view
  alias Blog.Landing
  import BlogWeb.LiveHelpers

  def mount(_params, _session, socket) do
    {:ok, 
      socket
      |> assign_sidebar_data()
      |> assign(active_nav: :readings, page_title: "Readings")
    }
  end

  def render(assigns) do
    ~H"""
    <div class="readings">
      <h1 class="text-neutral-850 text-4xl font-snpro mt-20 mb-10 tracking-tighter">
        Readings
      </h1>
      
      <p class="text-lg mb-8 text-gray-600">
        A curated collection of books, articles, and resources that have shaped my thinking.
      </p>

      <!-- Currently Reading -->
      <section class="mb-12">
        <h2 class="text-2xl font-bold mb-6 text-neutral-800">Currently Reading</h2>
        <div class="grid gap-6">
          <div class="flex gap-4 p-4 bg-gray-50 rounded-lg">
            <div class="w-20 h-28 bg-gray-200 rounded flex-shrink-0"></div>
            <div>
              <h3 class="font-bold text-lg">The Phoenix Project</h3>
              <p class="text-gray-600 text-sm mb-2">by Gene Kim, Kevin Behr, George Spafford</p>
              <p class="text-gray-500 text-sm">A novel about IT, DevOps, and helping your business win.</p>
            </div>
          </div>
        </div>
      </section>

      <!-- Recent Favorites -->
      <section class="mb-12">
        <h2 class="text-2xl font-bold mb-6 text-neutral-800">Recent Favorites</h2>
        <div class="grid gap-6">
          <div class="border-l-4 border-lava pl-4">
            <h3 class="font-bold text-lg">Domain-Driven Design</h3>
            <p class="text-gray-600 text-sm mb-2">by Eric Evans</p>
            <p class="text-gray-500">
              Essential reading for understanding how to model complex business domains in software.
            </p>
          </div>
          
          <div class="border-l-4 border-lava pl-4">
            <h3 class="font-bold text-lg">Designing Data-Intensive Applications</h3>
            <p class="text-gray-600 text-sm mb-2">by Martin Kleppmann</p>
            <p class="text-gray-500">
              The big ideas behind reliable, scalable, and maintainable systems.
            </p>
          </div>
          
          <div class="border-l-4 border-lava pl-4">
            <h3 class="font-bold text-lg">Programming Phoenix LiveView</h3>
            <p class="text-gray-600 text-sm mb-2">by Bruce A. Tate and Sophie DeBenedetto</p>
            <p class="text-gray-500">
              Interactive Elixir web programming without writing custom JavaScript.
            </p>
          </div>
        </div>
      </section>

      <!-- Articles & Essays -->
      <section class="mb-12">
        <h2 class="text-2xl font-bold mb-6 text-neutral-800">Articles & Essays</h2>
        <ul class="space-y-3">
          <li>
            <a href="#" class="text-blue-600 hover:underline">
              "The Twelve-Factor App" - Methodology for building SaaS apps
            </a>
          </li>
          <li>
            <a href="#" class="text-blue-600 hover:underline">
              "How to Build Good Software" - Li Hongyi
            </a>
          </li>
          <li>
            <a href="#" class="text-blue-600 hover:underline">
              "The Architecture of Open Source Applications" - Various Authors
            </a>
          </li>
        </ul>
      </section>

      <p class="text-gray-500 text-center italic">
        Reading list updated regularly...
      </p>
    </div>
    """
  end
end