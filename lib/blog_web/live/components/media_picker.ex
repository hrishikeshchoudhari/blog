defmodule BlogWeb.Components.MediaPicker do
  use Phoenix.Component

  def media_picker(assigns) do
    ~H"""
    <div id="media-picker" class="relative">
      <button
        type="button"
        phx-click="toggle-media-picker"
        class="inline-flex items-center px-3 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-chiffon-100"
      >
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
        Choose Image
      </button>

      <%= if assigns[:show_media_picker] do %>
        <div class="absolute z-50 mt-2 w-[600px] max-h-[500px] bg-white rounded-lg shadow-lg border border-neutral-200">
          <div class="sticky top-0 bg-white border-b border-neutral-200 p-3">
            <div class="flex justify-between items-center">
              <h3 class="font-medium text-neutral-850">Select Image</h3>
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
          </div>

          <div class="flex h-[400px]">
            <!-- Image Grid -->
            <div class="flex-1 p-3 overflow-y-auto border-r border-neutral-200">
              <%= if assigns[:media_items] == [] do %>
                <p class="text-center text-neutral-500 py-8">
                  No images uploaded yet.
                  <.link navigate="/admin/media" class="text-sacramento-600 hover:underline">
                    Upload images
                  </.link>
                </p>
              <% else %>
                <div class="grid grid-cols-3 gap-2">
                  <%= for item <- assigns[:media_items] do %>
                    <button
                      type="button"
                      phx-click="select-media"
                      phx-value-id={item.id}
                      class={"relative group cursor-pointer rounded overflow-hidden border-2 " <> if assigns[:selected_media] && assigns[:selected_media].id == item.id, do: "border-lava", else: "border-transparent hover:border-lava"}
                    >
                      <img
                        src={item.thumbnail_path || item.path}
                        alt={item.alt_text || item.original_filename}
                        class="w-full h-24 object-cover"
                      />
                      <div class="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-30 transition-opacity flex items-center justify-center">
                        <%= if assigns[:selected_media] && assigns[:selected_media].id == item.id do %>
                          <svg class="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                          </svg>
                        <% else %>
                          <svg class="w-6 h-6 text-white opacity-0 group-hover:opacity-100" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                          </svg>
                        <% end %>
                      </div>
                    </button>
                  <% end %>
                </div>
              <% end %>
            </div>

            <!-- Selected Image Options -->
            <div class="w-64 p-4 bg-neutral-50">
              <%= if assigns[:selected_media] do %>
                <div class="space-y-4">
                  <!-- Preview -->
                  <div>
                    <img
                      src={@selected_media.thumbnail_path || @selected_media.path}
                      alt={@selected_media.alt_text || @selected_media.original_filename}
                      class="w-full rounded-lg shadow-sm"
                    />
                    <p class="text-xs text-neutral-600 mt-2 truncate"><%= @selected_media.original_filename %></p>
                  </div>

                  <!-- Options -->
                  <div class="space-y-3">
                    <div>
                      <label class="block text-sm font-medium text-neutral-700 mb-1">Size</label>
                      <select
                        id="media-size"
                        name="media_size"
                        phx-change="update-media-size"
                        class="w-full text-sm rounded border-neutral-300"
                      >
                        <option value="thumbnail">Thumbnail (300px)</option>
                        <option value="medium" selected>Medium (800px)</option>
                        <option value="full">Full size</option>
                      </select>
                    </div>
                    
                    <div>
                      <label class="block text-sm font-medium text-neutral-700 mb-1">Alt Text</label>
                      <input
                        type="text"
                        id="media-alt"
                        name="media_alt"
                        value={@selected_media.alt_text || ""}
                        phx-blur="update-media-alt"
                        placeholder="Describe this image"
                        class="w-full text-sm rounded border-neutral-300"
                      />
                      <p class="text-xs text-neutral-500 mt-1">For accessibility</p>
                    </div>

                    <button
                      type="button"
                      phx-click="insert-media"
                      class="w-full px-4 py-2 bg-sacramento-600 text-white text-sm font-medium rounded hover:bg-sacramento-700 transition-colors"
                    >
                      Insert Image
                    </button>
                  </div>
                </div>
              <% else %>
                <div class="h-full flex items-center justify-center">
                  <p class="text-sm text-neutral-500 text-center">
                    Select an image from the left to configure options
                  </p>
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