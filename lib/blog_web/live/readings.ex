defmodule BlogWeb.Readings do
  use BlogWeb, :live_view
  alias Blog.Landing
  import BlogWeb.LiveHelpers
  import BlogWeb.Components.Pagination
  use Timex

  def mount(params, _session, socket) do
    page = String.to_integer(params["page"] || "1")
    paginated_data = Landing.list_readings(page, 20)
    
    {:ok, 
      socket
      |> assign_sidebar_data()
      |> assign(
        active_nav: :readings, 
        page_title: "Readings",
        readings: paginated_data.readings,
        readings_by_rating: paginated_data.readings_by_rating,
        page: paginated_data.page,
        total_pages: paginated_data.total_pages,
        total_readings: paginated_data.total_readings
      )
    }
  end
  
  def handle_params(params, _uri, socket) do
    page = String.to_integer(params["page"] || "1")
    paginated_data = Landing.list_readings(page, 20)
    
    {:noreply, 
      socket
      |> assign(
        readings: paginated_data.readings,
        readings_by_rating: paginated_data.readings_by_rating,
        page: paginated_data.page,
        total_pages: paginated_data.total_pages,
        total_readings: paginated_data.total_readings
      )
    }
  end

  def render(assigns) do
    ~H"""
    <div class="readings">
      <h1 class="text-neutral-850 text-4xl font-snpro mt-20 mb-10 tracking-tighter">
        Readings
      </h1>
      
      <p class="text-lg mb-8 text-gray-600">
        Book reviews, reading notes, and recommendations from my reading journey.
      </p>

      <%= if @readings == [] do %>
        <p class="text-gray-500 text-center italic">
          No reading reviews published yet. Check back soon!
        </p>
      <% else %>
        <!-- 5-Star Reads -->
        <%= if Map.get(@readings_by_rating, 5, []) != [] do %>
          <section class="mb-12">
            <h2 class="text-2xl font-bold mb-6 text-neutral-800 flex items-center gap-2">
              <span>Highly Recommended</span>
              <div class="flex text-yellow-500">
                <%= for _ <- 1..5 do %>
                  <svg class="w-5 h-5 fill-current" viewBox="0 0 20 20">
                    <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"/>
                  </svg>
                <% end %>
              </div>
            </h2>
            <div class="grid gap-6">
              <%= for reading <- Map.get(@readings_by_rating, 5, []) do %>
                <.reading_card reading={reading} />
              <% end %>
            </div>
          </section>
        <% end %>

        <!-- 4-Star Reads -->
        <%= if Map.get(@readings_by_rating, 4, []) != [] do %>
          <section class="mb-12">
            <h2 class="text-2xl font-bold mb-6 text-neutral-800 flex items-center gap-2">
              <span>Great Reads</span>
              <div class="flex text-yellow-500">
                <%= for _ <- 1..4 do %>
                  <svg class="w-5 h-5 fill-current" viewBox="0 0 20 20">
                    <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"/>
                  </svg>
                <% end %>
              </div>
            </h2>
            <div class="grid gap-6">
              <%= for reading <- Map.get(@readings_by_rating, 4, []) do %>
                <.reading_card reading={reading} />
              <% end %>
            </div>
          </section>
        <% end %>

        <!-- Other Ratings -->
        <%= for rating <- [3, 2, 1], Map.get(@readings_by_rating, rating, []) != [] do %>
          <section class="mb-12">
            <h2 class="text-2xl font-bold mb-6 text-neutral-800 flex items-center gap-2">
              <span><%= rating_title(rating) %></span>
              <div class="flex text-yellow-500">
                <%= for i <- 1..rating do %>
                  <svg class="w-5 h-5 fill-current" viewBox="0 0 20 20">
                    <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"/>
                  </svg>
                <% end %>
              </div>
            </h2>
            <div class="grid gap-6">
              <%= for reading <- Map.get(@readings_by_rating, rating, []) do %>
                <.reading_card reading={reading} />
              <% end %>
            </div>
          </section>
        <% end %>

        <!-- Books without ratings -->
        <% unrated = Enum.filter(@readings, &(is_nil(&1.rating))) %>
        <%= if unrated != [] do %>
          <section class="mb-12">
            <h2 class="text-2xl font-bold mb-6 text-neutral-800">Other Readings</h2>
            <div class="grid gap-6">
              <%= for reading <- unrated do %>
                <.reading_card reading={reading} />
              <% end %>
            </div>
          </section>
        <% end %>

        <div class="text-center text-gray-500 mt-12">
          <p class="text-sm">
            Total Books Reviewed: <span class="font-semibold"><%= length(@readings) %></span>
          </p>
        </div>
      <% end %>
      
      <!-- Pagination Controls -->
      <.pagination 
        page={@page} 
        total_pages={@total_pages} 
        total_items={@total_readings} 
        base_url="/readings" 
        item_name="books"
      />
    </div>
    """
  end

  def reading_card(assigns) do
    ~H"""
    <.link navigate={"/reading/" <> @reading.slug} class="block">
      <div class="flex gap-6 p-6 bg-white rounded-lg border-2 border-gray-200 hover:border-lava transition-all hover:shadow-lg">
        <!-- Book cover placeholder -->
        <div class="w-24 h-32 bg-gradient-to-br from-sacramento-100 to-sacramento-200 rounded flex-shrink-0 flex items-center justify-center">
          <svg class="w-12 h-12 text-sacramento-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
          </svg>
        </div>
        
        <div class="flex-1">
          <h3 class="font-bold text-xl mb-1 text-neutral-850 hover:text-lava transition-colors">
            <%= @reading.title %>
          </h3>
          <%= if @reading.author do %>
            <p class="text-gray-600 text-sm mb-2">by <%= @reading.author %></p>
          <% end %>
          
          <p class="text-gray-700 mb-3">
            <%= @reading.meta_description || String.slice(@reading.raw_body || "", 0, 150) %>...
          </p>
          
          <div class="flex items-center gap-4 text-sm">
            <%= if @reading.rating do %>
              <div class="flex text-yellow-500">
                <%= for i <- 1..5 do %>
                  <svg class={"w-4 h-4 #{if i <= @reading.rating, do: "fill-current", else: "fill-gray-300"}"} viewBox="0 0 20 20">
                    <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"/>
                  </svg>
                <% end %>
              </div>
            <% end %>
            
            <%= if @reading.date_read do %>
              <span class="text-gray-500">
                Read <%= Timex.format!(@reading.date_read, "{Mfull} {YYYY}") %>
              </span>
            <% end %>
            
            <%= if @reading.isbn do %>
              <span class="text-gray-400">
                ISBN: <%= @reading.isbn %>
              </span>
            <% end %>
          </div>
        </div>
      </div>
    </.link>
    """
  end

  defp rating_title(3), do: "Worth Reading"
  defp rating_title(2), do: "Mixed Feelings"
  defp rating_title(1), do: "Not Recommended"
  defp rating_title(_), do: "Other Books"
end