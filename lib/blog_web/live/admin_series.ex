defmodule BlogWeb.AdminSeries do
  use BlogWeb, :admin_live_view
  alias Blog.Admin
  alias Blog.Admin.Series
  alias Blog.Media

  def mount(_params, _session, socket) do
    user = socket.assigns.current_users
    series_list = Admin.list_series(user.id)
    changeset = Series.changeset(%Series{}, %{})
    media_items = Media.list_media_items(user.id)
    
    {:ok,
     socket
     |> assign(
       series_list: series_list,
       page_title: "Manage Series",
       active_admin_nav: :series,
       form: to_form(changeset),
       editing_series: nil,
       show_media_picker: false,
       media_items: media_items,
       selected_media: nil
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-neutral-850">Series</h1>
        <p class="mt-2 text-neutral-600">Create collections of related posts.</p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Series Form -->
        <div class="lg:col-span-1">
          <div class="bg-white rounded-lg shadow-sm p-6 border-2 border-chiffon-200">
            <h2 class="text-lg font-semibold text-neutral-850 mb-4">
              <%= if @editing_series, do: "Edit Series", else: "New Series" %>
            </h2>
            
            <.form for={@form} phx-submit={if @editing_series, do: "update", else: "create"} class="space-y-4">
              <div>
                <.input
                  field={@form[:title]}
                  type="text"
                  label="Title"
                  placeholder="My Tutorial Series"
                  required
                />
              </div>
              
              <div>
                <.input
                  field={@form[:slug]}
                  type="text"
                  label="Slug"
                  placeholder="auto-generated-from-title"
                />
                <p class="mt-1 text-sm text-neutral-500">Leave blank to auto-generate</p>
              </div>
              
              <div>
                <.input
                  field={@form[:description]}
                  type="textarea"
                  label="Description"
                  rows="3"
                  placeholder="What is this series about?"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-neutral-700 mb-2">
                  Cover Image
                </label>
                <div class="flex gap-2">
                  <.input
                    field={@form[:cover_image]}
                    type="text"
                    placeholder="URL to cover image"
                    class="flex-1"
                  />
                  <button
                    type="button"
                    phx-click="toggle-media-picker"
                    class="px-3 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-chiffon-100"
                  >
                    Choose
                  </button>
                </div>
              </div>
              
              <div>
                <label class="flex items-center">
                  <.input
                    field={@form[:is_complete]}
                    type="checkbox"
                    class="mr-2"
                  />
                  <span class="text-sm font-medium text-neutral-700">Series is complete</span>
                </label>
                <p class="mt-1 text-sm text-neutral-500 ml-6">Mark when all posts are published</p>
              </div>
              
              <div class="flex gap-2">
                <.button 
                  type="submit"
                  class="flex-1 inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-sacramento-600 hover:bg-sacramento-700"
                >
                  <%= if @editing_series, do: "Update", else: "Create" %> Series
                </.button>
                
                <%= if @editing_series do %>
                  <.button
                    type="button"
                    phx-click="cancel-edit"
                    class="px-4 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-chiffon-100"
                  >
                    Cancel
                  </.button>
                <% end %>
              </div>
            </.form>
          </div>
        </div>

        <!-- Series List -->
        <div class="lg:col-span-2">
          <div class="bg-white rounded-lg shadow-sm border-2 border-chiffon-200">
            <div class="px-6 py-4 border-b border-chiffon-200">
              <h2 class="text-lg font-semibold text-neutral-850">All Series</h2>
            </div>
            
            <%= if @series_list == [] do %>
              <div class="p-8 text-center text-neutral-500">
                <svg class="mx-auto h-12 w-12 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                </svg>
                <p class="mt-2">No series yet. Create your first series!</p>
              </div>
            <% else %>
              <div class="divide-y divide-neutral-200">
                <%= for series <- @series_list do %>
                  <div class="px-6 py-4 hover:bg-chiffon-50 transition-colors">
                    <div class="flex items-start justify-between">
                      <div class="flex-1">
                        <div class="flex items-center gap-2">
                          <h3 class="font-medium text-neutral-850"><%= series.title %></h3>
                          <%= if series.is_complete do %>
                            <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                              Complete
                            </span>
                          <% else %>
                            <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                              Ongoing
                            </span>
                          <% end %>
                        </div>
                        <p class="text-sm text-neutral-500 mt-1">/<%= series.slug %></p>
                        <%= if series.description do %>
                          <p class="text-sm text-neutral-600 mt-2"><%= series.description %></p>
                        <% end %>
                        <div class="mt-2 text-sm text-neutral-500">
                          Created <%= Timex.format!(series.inserted_at, "{relative}", :relative) %>
                        </div>
                      </div>
                      
                      <%= if series.cover_image do %>
                        <img 
                          src={series.cover_image} 
                          alt={series.title <> " cover"} 
                          class="w-20 h-20 object-cover rounded-lg ml-4"
                        />
                      <% end %>
                    </div>
                    
                    <div class="flex items-center gap-4 mt-4">
                      <button
                        type="button"
                        phx-click="view-posts"
                        phx-value-id={series.id}
                        class="text-sacramento-600 hover:text-sacramento-700 font-medium text-sm"
                      >
                        View Posts
                      </button>
                      <button
                        type="button"
                        phx-click="edit"
                        phx-value-id={series.id}
                        class="text-sacramento-600 hover:text-sacramento-700 font-medium text-sm"
                      >
                        Edit
                      </button>
                      <button
                        type="button"
                        phx-click="delete"
                        phx-value-id={series.id}
                        data-confirm="Are you sure you want to delete this series? Posts will not be deleted."
                        class="text-red-600 hover:text-red-700 font-medium text-sm"
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>

      <!-- Media Picker Modal -->
      <%= if @show_media_picker do %>
        <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" phx-click="close-media-picker">
          <div class="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[80vh] overflow-hidden" phx-click-away="close-media-picker">
            <div class="p-4 border-b border-neutral-200 flex justify-between items-center">
              <h3 class="text-lg font-semibold">Select Cover Image</h3>
              <button
                type="button"
                phx-click="close-media-picker"
                class="text-neutral-400 hover:text-neutral-600"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            
            <div class="p-4 overflow-y-auto max-h-[60vh]">
              <%= if @media_items == [] do %>
                <p class="text-center text-neutral-500 py-8">
                  No images uploaded yet.
                  <.link navigate="/admin/media" class="text-sacramento-600 hover:underline">
                    Upload images
                  </.link>
                </p>
              <% else %>
                <div class="grid grid-cols-3 md:grid-cols-4 gap-4">
                  <%= for item <- @media_items do %>
                    <button
                      type="button"
                      phx-click="select-media"
                      phx-value-id={item.id}
                      class={"relative group cursor-pointer rounded overflow-hidden border-2 " <> if @selected_media && @selected_media.id == item.id, do: "border-lava", else: "border-transparent hover:border-lava"}
                    >
                      <img
                        src={item.thumbnail_path || item.path}
                        alt={item.alt_text || item.original_filename}
                        class="w-full h-32 object-cover"
                      />
                    </button>
                  <% end %>
                </div>
              <% end %>
            </div>
            
            <%= if @selected_media do %>
              <div class="p-4 border-t border-neutral-200 flex justify-end">
                <button
                  type="button"
                  phx-click="use-selected-media"
                  class="px-4 py-2 bg-sacramento-600 text-white text-sm font-medium rounded hover:bg-sacramento-700"
                >
                  Use Selected Image
                </button>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("create", %{"series" => series_params}, socket) do
    series_params = Map.put(series_params, "user_id", socket.assigns.current_users.id)
    
    case Admin.create_series(series_params) do
      {:ok, _series} ->
        {:noreply,
         socket
         |> put_flash(:info, "Series created successfully")
         |> assign(
           series_list: Admin.list_series(socket.assigns.current_users.id),
           form: to_form(Series.changeset(%Series{}, %{}))
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    series = Admin.get_series!(id)
    changeset = Series.changeset(series, %{})
    
    {:noreply,
     assign(socket,
       editing_series: series,
       form: to_form(changeset)
     )}
  end

  def handle_event("cancel-edit", _, socket) do
    {:noreply,
     assign(socket,
       editing_series: nil,
       form: to_form(Series.changeset(%Series{}, %{}))
     )}
  end

  def handle_event("update", %{"series" => series_params}, socket) do
    case Admin.update_series(socket.assigns.editing_series, series_params) do
      {:ok, _series} ->
        {:noreply,
         socket
         |> put_flash(:info, "Series updated successfully")
         |> assign(
           series_list: Admin.list_series(socket.assigns.current_users.id),
           editing_series: nil,
           form: to_form(Series.changeset(%Series{}, %{}))
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    series = Admin.get_series!(id)
    {:ok, _} = Admin.delete_series(series)
    
    {:noreply,
     socket
     |> put_flash(:info, "Series deleted successfully")
     |> assign(series_list: Admin.list_series(socket.assigns.current_users.id))}
  end

  def handle_event("view-posts", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: "/admin/posts?series_id=#{id}")}
  end

  def handle_event("toggle-media-picker", _, socket) do
    {:noreply, assign(socket, show_media_picker: !socket.assigns.show_media_picker)}
  end

  def handle_event("close-media-picker", _, socket) do
    {:noreply, assign(socket, show_media_picker: false, selected_media: nil)}
  end

  def handle_event("select-media", %{"id" => id}, socket) do
    media = Enum.find(socket.assigns.media_items, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, selected_media: media)}
  end

  def handle_event("use-selected-media", _, socket) do
    if media = socket.assigns.selected_media do
      form = socket.assigns.form
      updated_form = 
        form.source
        |> Ecto.Changeset.put_change(:cover_image, media.path)
        |> to_form()
      
      {:noreply,
       socket
       |> assign(form: updated_form, show_media_picker: false, selected_media: nil)}
    else
      {:noreply, socket}
    end
  end
end