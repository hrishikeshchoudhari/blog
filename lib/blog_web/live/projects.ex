defmodule BlogWeb.Projects do
  use BlogWeb, :live_view
  alias Blog.Landing
  import BlogWeb.LiveHelpers
  use Timex

  def mount(_params, _session, socket) do
    projects = Landing.all_projects()
    
    {:ok, 
      socket
      |> assign_sidebar_data()
      |> assign(
        active_nav: :projects, 
        page_title: "Projects",
        projects: projects
      )
    }
  end

  def render(assigns) do
    ~H"""
    <div class="projects">
      <h1 class="text-neutral-850 text-4xl font-snpro mt-20 mb-10 tracking-tighter">
        Projects
      </h1>
      
      <div class="grid gap-8 mb-12">
        <%= if @projects == [] do %>
          <p class="text-gray-500 text-center italic">
            No projects published yet. Check back soon!
          </p>
        <% else %>
          <%= for project <- @projects do %>
            <.link navigate={"/project/" <> project.slug} class="block">
              <div class="border-2 border-gray-200 rounded-lg p-6 hover:border-lava transition-all hover:shadow-lg">
                <div class="flex items-start justify-between">
                  <div class="flex-1">
                    <h2 class="text-2xl font-bold mb-3 text-neutral-850 hover:text-lava transition-colors">
                      <%= project.title %>
                    </h2>
                    <p class="text-gray-600 mb-4">
                      <%= project.meta_description || String.slice(project.raw_body || "", 0, 200) %>...
                    </p>
                    
                    <%= if project.tech_stack && project.tech_stack != [] do %>
                      <div class="flex gap-2 flex-wrap mb-4">
                        <%= for tech <- project.tech_stack do %>
                          <span class="text-sm bg-sacramento-50 text-sacramento-700 px-3 py-1 rounded-full">
                            <%= tech %>
                          </span>
                        <% end %>
                      </div>
                    <% end %>
                    
                    <div class="flex items-center gap-4 text-sm text-gray-500">
                      <%= if project.demo_url do %>
                        <span class="flex items-center gap-1">
                          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                          </svg>
                          Demo Available
                        </span>
                      <% end %>
                      <%= if project.github_url do %>
                        <span class="flex items-center gap-1">
                          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                          </svg>
                          Source Code
                        </span>
                      <% end %>
                      <span>
                        <%= Timex.format!(project.publishedDate, "{Mfull} {YYYY}") %>
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </.link>
          <% end %>
        <% end %>
      </div>
      
      <%= if @projects != [] do %>
        <div class="text-center text-gray-500 mt-12">
          <p class="text-sm">
            Total Projects: <span class="font-semibold"><%= length(@projects) %></span>
          </p>
        </div>
      <% end %>
    </div>
    """
  end
end