defmodule BlogWeb.MediaLibraryLive do
  use BlogWeb, :admin_live_view
  alias Blog.Media
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_users
    media_items = Media.list_media_items(user.id)
    
    {:ok,
     socket
     |> assign(
       active_admin_nav: :media,
       page_title: "Media Library",
       media_items: media_items,
       selected_item: nil,
       show_upload: false
     )
     |> allow_upload(:images,
       accept: ~w(.jpg .jpeg .png .gif .webp),
       max_entries: 10,
       max_file_size: 10_000_000
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8 flex justify-between items-center">
        <div>
          <h1 class="text-3xl font-bold text-neutral-850">Media Library</h1>
          <p class="mt-2 text-neutral-600">Manage your uploaded images</p>
        </div>
        <button
          phx-click="toggle-upload"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-lava hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500"
        >
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Upload Images
        </button>
      </div>

      <!-- Upload Section -->
      <%= if @show_upload do %>
        <div class="mb-8 bg-white rounded-lg shadow-sm border-2 border-chiffon-200 p-6">
          <h2 class="text-lg font-semibold text-neutral-850 mb-4">Upload New Images</h2>
          
          <form id="upload-form" phx-submit="save" phx-change="validate">
            <div class="space-y-4">
              <!-- Drag and Drop Area -->
              <div
                class="border-2 border-dashed border-neutral-300 rounded-lg p-8 text-center hover:border-lava transition-colors"
                phx-drop-target={@uploads.images.ref}
              >
                <svg class="mx-auto h-12 w-12 text-neutral-400" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                  <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
                </svg>
                <p class="mt-2 text-sm text-neutral-600">
                  <label for={@uploads.images.ref} class="cursor-pointer text-lava hover:text-orange-700">
                    <span>Upload files</span>
                    <.live_file_input upload={@uploads.images} id={@uploads.images.ref} class="sr-only" />
                  </label>
                  or drag and drop
                </p>
                <p class="text-xs text-neutral-500">PNG, JPG, GIF, WEBP up to 10MB</p>
              </div>

              <!-- Upload Preview -->
              <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <%= for entry <- @uploads.images.entries do %>
                  <div class="relative group">
                    <.live_img_preview entry={entry} class="w-full h-32 object-cover rounded-lg" />
                    <div class="absolute inset-0 bg-black bg-opacity-50 opacity-0 group-hover:opacity-100 transition-opacity rounded-lg flex items-center justify-center">
                      <button
                        type="button"
                        phx-click="cancel-upload"
                        phx-value-ref={entry.ref}
                        class="text-white hover:text-red-400"
                      >
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                      </button>
                    </div>
                    <progress value={entry.progress} max="100" class="w-full h-1 mt-2">
                      <%= entry.progress %>%
                    </progress>
                    <%= for err <- upload_errors(@uploads.images, entry) do %>
                      <p class="text-xs text-red-600 mt-1"><%= error_to_string(err) %></p>
                    <% end %>
                  </div>
                <% end %>
              </div>

              <!-- Upload Errors -->
              <%= for err <- upload_errors(@uploads.images) do %>
                <p class="text-sm text-red-600"><%= error_to_string(err) %></p>
              <% end %>

              <!-- Upload Button -->
              <%= if length(@uploads.images.entries) > 0 do %>
                <button
                  type="submit"
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-sacramento-600 hover:bg-sacramento-700"
                >
                  Upload <%= length(@uploads.images.entries) %> image(s)
                </button>
              <% end %>
            </div>
          </form>
        </div>
      <% end %>

      <!-- Media Grid -->
      <div class="bg-white rounded-lg shadow-sm border-2 border-chiffon-200">
        <%= if @media_items == [] do %>
          <div class="p-12 text-center">
            <svg class="mx-auto h-12 w-12 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            <h3 class="mt-2 text-sm font-medium text-neutral-900">No images</h3>
            <p class="mt-1 text-sm text-neutral-500">Get started by uploading an image.</p>
          </div>
        <% else %>
          <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4 p-6">
            <%= for item <- @media_items do %>
              <div
                class={"relative group cursor-pointer rounded-lg overflow-hidden #{if @selected_item && @selected_item.id == item.id, do: "ring-2 ring-lava"}"}
                phx-click="select-item"
                phx-value-id={item.id}
              >
                <img
                  src={item.thumbnail_path || item.path}
                  alt={item.alt_text || item.original_filename}
                  class="w-full h-32 object-cover"
                />
                <div class="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-30 transition-opacity" />
                <div class="absolute bottom-0 left-0 right-0 p-2 bg-gradient-to-t from-black/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
                  <p class="text-xs text-white truncate"><%= item.original_filename %></p>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>

      <!-- Selected Item Details -->
      <%= if @selected_item do %>
        <div class="mt-8 bg-white rounded-lg shadow-sm border-2 border-chiffon-200 p-6">
          <div class="grid md:grid-cols-2 gap-6">
            <!-- Preview -->
            <div>
              <img
                src={@selected_item.medium_path || @selected_item.path}
                alt={@selected_item.alt_text || @selected_item.original_filename}
                class="w-full rounded-lg"
              />
            </div>

            <!-- Details -->
            <div>
              <h3 class="text-lg font-semibold text-neutral-850 mb-4">Image Details</h3>
              
              <.form for={to_form(%{}, as: :media)} phx-submit="update-media" class="space-y-4">
                <input type="hidden" name="media[id]" value={@selected_item.id} />
                
                <div>
                  <label class="block text-sm font-medium text-neutral-700 mb-1">Alt Text</label>
                  <input
                    type="text"
                    name="media[alt_text]"
                    value={@selected_item.alt_text}
                    placeholder="Describe this image for accessibility"
                    class="w-full rounded-md border-neutral-300"
                  />
                  <p class="mt-1 text-xs text-neutral-500">Important for SEO and accessibility</p>
                </div>

                <div>
                  <label class="block text-sm font-medium text-neutral-700 mb-1">Caption</label>
                  <textarea
                    name="media[caption]"
                    rows="2"
                    placeholder="Optional caption"
                    class="w-full rounded-md border-neutral-300"
                  ><%= @selected_item.caption %></textarea>
                </div>

                <div class="space-y-2 text-sm text-neutral-600">
                  <p><strong>Filename:</strong> <%= @selected_item.original_filename %></p>
                  <p><strong>Size:</strong> <%= format_bytes(@selected_item.size) %></p>
                  <%= if @selected_item.width && @selected_item.height do %>
                    <p><strong>Dimensions:</strong> <%= @selected_item.width %>×<%= @selected_item.height %></p>
                  <% end %>
                  <p><strong>Uploaded:</strong> <%= Calendar.strftime(@selected_item.inserted_at, "%B %d, %Y") %></p>
                </div>

                <div class="pt-4 space-y-3">
                  <button
                    type="submit"
                    class="w-full inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-sacramento-600 hover:bg-sacramento-700"
                  >
                    Save Changes
                  </button>

                  <div class="grid grid-cols-2 gap-3">
                    <button
                      type="button"
                      phx-click="copy-url"
                      phx-value-url={@selected_item.path}
                      class="inline-flex justify-center items-center px-3 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-neutral-50"
                    >
                      <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                      Copy URL
                    </button>

                    <button
                      type="button"
                      phx-click="delete-item"
                      phx-value-id={@selected_item.id}
                      data-confirm="Are you sure you want to delete this image?"
                      class="inline-flex justify-center items-center px-3 py-2 border border-red-300 text-sm font-medium rounded-md text-red-700 bg-white hover:bg-red-50"
                    >
                      <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                      Delete
                    </button>
                  </div>
                </div>
              </.form>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("toggle-upload", _, socket) do
    {:noreply, assign(socket, :show_upload, !socket.assigns.show_upload)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    user = socket.assigns.current_users
    
    uploaded_files =
      consume_uploaded_entries(socket, :images, fn %{path: path} = meta, entry ->
        # Create a proper upload entry structure for process_upload
        upload_entry = %{
          path: path,
          client_name: entry.client_name,
          client_type: entry.client_type,
          client_size: entry.client_size
        }
        
        case Media.process_upload(upload_entry, user.id) do
          {:ok, media_item} -> {:ok, media_item}
          {:error, _} -> {:postpone, :error}
        end
      end)

    successful_uploads = Enum.filter(uploaded_files, fn
      {:ok, _} -> true
      _ -> false
    end)

    socket = if length(successful_uploads) > 0 do
      socket
      |> put_flash(:info, "Successfully uploaded #{length(successful_uploads)} image(s)")
      |> assign(:media_items, Media.list_media_items(user.id))
      |> assign(:show_upload, false)
    else
      put_flash(socket, :error, "Failed to upload images")
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("select-item", %{"id" => id}, socket) do
    user = socket.assigns.current_users
    item = Media.get_media_item!(id, user.id)
    {:noreply, assign(socket, :selected_item, item)}
  end

  @impl true
  def handle_event("update-media", %{"media" => params}, socket) do
    user = socket.assigns.current_users
    item = Media.get_media_item!(params["id"], user.id)
    
    case Media.update_media_item(item, params) do
      {:ok, updated_item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Image details updated")
         |> assign(:selected_item, updated_item)
         |> assign(:media_items, Media.list_media_items(user.id))}
      
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update image")}
    end
  end

  @impl true
  def handle_event("copy-url", %{"url" => url}, socket) do
    # In a real app, you'd use JavaScript to copy to clipboard
    {:noreply, put_flash(socket, :info, "URL copied: #{url}")}
  end

  @impl true
  def handle_event("delete-item", %{"id" => id}, socket) do
    user = socket.assigns.current_users
    item = Media.get_media_item!(id, user.id)
    
    case Media.delete_media_item(item) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Image deleted")
         |> assign(:selected_item, nil)
         |> assign(:media_items, Media.list_media_items(user.id))}
      
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete image")}
    end
  end

  defp error_to_string(:too_large), do: "File too large (max 10MB)"
  defp error_to_string(:too_many_files), do: "Too many files (max 10)"
  defp error_to_string(:not_accepted), do: "Invalid file type (only images allowed)"

  defp format_bytes(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_bytes(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_bytes(bytes), do: "#{Float.round(bytes / 1_048_576, 1)} MB"
end