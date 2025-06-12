defmodule BlogWeb.TagsActions do
    use BlogWeb, :admin_live_view
    require Logger
    alias Blog.Admin
    alias Blog.Admin.Tag


    def mount(_params, _session, socket) do
      changeset = Admin.Tag.changeset(%Tag{}, %{})
      tags = Admin.all_tags()
      {:ok,
        assign(socket,
          tags: tags,
          active_admin_nav: :tags,
          page_title: "Manage Tags",
          form: to_form(changeset),
          show_form: false)
      }
    end

    def render(assigns) do
      ~H"""
        <div class="max-w-6xl mx-auto">
          <!-- Page Header -->
          <div class="mb-8 flex justify-between items-center">
            <div>
              <h1 class="text-3xl font-bold text-neutral-850">Tags</h1>
              <p class="mt-2 text-neutral-600">Organize your content with tags</p>
            </div>
            <button
              phx-click="toggle-form"
              class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-lava hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500"
            >
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
              </svg>
              New Tag
            </button>
          </div>

          <!-- Add Tag Form -->
          <%= if @show_form do %>
          <div class="bg-white rounded-lg shadow-sm p-6 mb-8 border-2 border-chiffon-200">
            <h2 class="text-lg font-semibold text-neutral-850 mb-4">Create New Tag</h2>
            <.form for={@form} phx-submit="save-tag" class="space-y-4">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-neutral-700 mb-2">Tag Name</label>
                  <.input 
                    id="name" 
                    field={@form[:name]} 
                    type="text" 
                    placeholder="e.g., Technology" 
                    class="w-full"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-neutral-700 mb-2">URL Slug</label>
                  <.input 
                    id="slug" 
                    field={@form[:slug]} 
                    type="text" 
                    placeholder="e.g., technology" 
                    class="w-full"
                  />
                </div>
              </div>
              <div>
                <label class="block text-sm font-medium text-neutral-700 mb-2">Description</label>
                <.input 
                  id="description" 
                  field={@form[:description]} 
                  type="textarea" 
                  placeholder="Brief description of this tag" 
                  class="w-full"
                  rows="3"
                />
              </div>
              <div class="flex justify-end space-x-3">
                <button
                  type="button"
                  phx-click="toggle-form"
                  class="px-4 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-chiffon-100"
                >
                  Cancel
                </button>
                <.button 
                  id="save-tag-btn" 
                  class="px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-lava hover:bg-orange-700"
                >
                  Save Tag
                </.button>
              </div>
            </.form>
          </div>
          <% end %>

          <!-- Tags List -->
          <div class="bg-white rounded-lg shadow-sm border-2 border-chiffon-200">
            <div class="px-6 py-4 border-b border-chiffon-200">
              <h2 class="text-lg font-semibold text-neutral-850">All Tags (<%= length(@tags) %>)</h2>
            </div>
            <div class="p-6">
              <%= if @tags == [] do %>
                <p class="text-neutral-500 text-center py-8">No tags yet. Create your first tag to get started.</p>
              <% else %>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  <%= for tag <- @tags do %>
                    <div class="border border-neutral-200 rounded-lg p-4 hover:border-lava transition-colors">
                      <div class="flex justify-between items-start mb-2">
                        <h3 class="font-semibold text-neutral-850">
                          <.link navigate={"/tag/#{tag.slug}"} class="hover:text-lava">
                            <%= tag.name %>
                          </.link>
                        </h3>
                        <div class="flex space-x-1">
                          <button class="text-neutral-400 hover:text-neutral-600">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                            </svg>
                          </button>
                          <button class="text-neutral-400 hover:text-salmon-600">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                            </svg>
                          </button>
                        </div>
                      </div>
                      <p class="text-sm text-neutral-500 mb-2">/<%= tag.slug %></p>
                      <%= if tag.description do %>
                        <p class="text-sm text-neutral-600"><%= tag.description %></p>
                      <% else %>
                        <p class="text-sm text-neutral-400 italic">No description</p>
                      <% end %>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      """
    end

    def handle_event("toggle-form", _params, socket) do
      {:noreply, assign(socket, show_form: !socket.assigns.show_form)}
    end

    def handle_event("save-tag", %{"tag" => tag_params}, socket) do
      case Admin.save_tag(tag_params) do
        {:ok, tag} ->
          socket =
            socket
            |> update(:tags, fn tags -> [tag | tags] end )
            |> put_flash(:info, "Tag saved successfully!")
            |> assign(form: to_form(Admin.Tag.changeset(%Tag{}, %{})), show_form: false)

          {:noreply, socket}

        {:error, changeset} ->
          socket =
            socket
            |> put_flash(:error, "Failed to save tag.")
            |> assign(:form, to_form(changeset))

          {:noreply, socket}
      end
    end

end
