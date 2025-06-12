defmodule BlogWeb.AdminPages do
  use BlogWeb, :admin_live_view
  alias Blog.{Landing, Page}
  require LiveMonacoEditor

  def mount(_params, _session, socket) do
    pages = Landing.list_pages()
    
    {:ok, assign(socket,
      active_admin_nav: :pages,
      page_title: "Manage Pages",
      pages: pages,
      editing_page: nil,
      form: nil
    )}
  end

  def handle_event("edit-page", %{"id" => id}, socket) do
    page = Enum.find(socket.assigns.pages, &(&1.id == String.to_integer(id)))
    changeset = Page.changeset(page, %{})
    
    {:noreply, assign(socket,
      editing_page: page,
      form: to_form(changeset)
    )}
  end

  def handle_event("cancel-edit", _, socket) do
    {:noreply, assign(socket, editing_page: nil, form: nil)}
  end

  def handle_event("set_editor_value", %{"value" => content}, socket) do
    {:noreply, assign(socket, :editor_value, content)}
  end

  def handle_event("save-page", %{"page" => page_params}, socket) do
    page_params = Map.put(page_params, "content", socket.assigns[:editor_value] || "")
    
    case Landing.update_page(socket.assigns.editing_page, page_params) do
      {:ok, updated_page} ->
        pages = Landing.list_pages()
        
        {:noreply,
         socket
         |> put_flash(:info, "Page updated successfully!")
         |> assign(pages: pages, editing_page: nil, form: nil)}
      
      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to update page")
         |> assign(form: to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-neutral-850">Pages</h1>
        <p class="mt-2 text-neutral-600">Manage your static pages content</p>
      </div>

      <%= if @editing_page do %>
        <!-- Edit Form -->
        <div class="bg-white rounded-lg shadow-sm border-2 border-chiffon-200 p-6">
          <h2 class="text-xl font-bold text-neutral-850 mb-4">
            Editing: <%= @editing_page.title %>
          </h2>
          
          <.form for={@form} phx-submit="save-page" class="space-y-6">
            <div>
              <label class="block text-sm font-medium text-neutral-700 mb-2">Title</label>
              <.input field={@form[:title]} type="text" class="w-full" />
            </div>

            <div>
              <label class="block text-sm font-medium text-neutral-700 mb-2">URL Slug</label>
              <.input field={@form[:slug]} type="text" class="w-full" disabled />
              <p class="mt-1 text-sm text-neutral-500">URL: /<%= @editing_page.slug %></p>
            </div>

            <div>
              <label class="block text-sm font-medium text-neutral-700 mb-2">Meta Description</label>
              <.input field={@form[:meta_description]} type="textarea" rows="2" class="w-full" />
            </div>

            <div>
              <label class="block text-sm font-medium text-neutral-700 mb-2">Content (HTML)</label>
              <div class="border border-neutral-200 rounded-lg overflow-hidden">
                <LiveMonacoEditor.code_editor 
                  style="min-height: 400px" 
                  id="content" 
                  value={@editing_page.content || ""}
                  class="w-full" 
                  change="set_editor_value" 
                  phx-debounce="1000"
                  opts={
                    Map.merge(
                      LiveMonacoEditor.default_opts(),
                      %{
                        "language" => "html",
                        "wordWrap" => "on",
                        "theme" => "vs-light",
                        "minimap" => %{"enabled" => false},
                        "fontSize" => 16,
                        "lineHeight" => 24,
                        "padding" => %{"top" => 20, "bottom" => 20}
                      }
                    )
                  }
                />
              </div>
              <p class="mt-2 text-sm text-neutral-500">
                You can use HTML, including Tailwind classes. For the About page, you can add timeline sections, achievement cards, etc.
              </p>
            </div>

            <div class="flex justify-between items-center pt-4 border-t border-neutral-200">
              <button
                type="button"
                phx-click="cancel-edit"
                class="px-4 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-chiffon-100"
              >
                Cancel
              </button>
              
              <div class="flex space-x-3">
                <.link 
                  navigate={"/" <> @editing_page.slug}
                  target="_blank"
                  class="inline-flex items-center px-4 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-chiffon-100"
                >
                  <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                  </svg>
                  Preview
                </.link>
                
                <button
                  type="submit"
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-lava hover:bg-orange-700"
                >
                  <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V2" />
                  </svg>
                  Save Changes
                </button>
              </div>
            </div>
          </.form>
        </div>
      <% else %>
        <!-- Pages List -->
        <div class="bg-white rounded-lg shadow-sm border-2 border-chiffon-200">
          <div class="px-6 py-4 border-b border-chiffon-200">
            <h2 class="text-lg font-semibold text-neutral-850">All Pages</h2>
          </div>
          <div class="p-6">
            <div class="grid gap-4">
              <%= for page <- @pages do %>
                <div class="border border-neutral-200 rounded-lg p-4 hover:border-lava transition-colors">
                  <div class="flex justify-between items-start">
                    <div>
                      <h3 class="font-semibold text-neutral-850 text-lg"><%= page.title %></h3>
                      <p class="text-sm text-neutral-500 mt-1">/<%= page.slug %></p>
                      <%= if page.meta_description do %>
                        <p class="text-sm text-neutral-600 mt-2"><%= page.meta_description %></p>
                      <% end %>
                    </div>
                    <div class="flex space-x-2">
                      <.link 
                        navigate={"/" <> page.slug}
                        target="_blank"
                        class="text-neutral-400 hover:text-neutral-600"
                      >
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                        </svg>
                      </.link>
                      <button 
                        phx-click="edit-page" 
                        phx-value-id={page.id}
                        class="text-neutral-400 hover:text-neutral-600"
                      >
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                      </button>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end