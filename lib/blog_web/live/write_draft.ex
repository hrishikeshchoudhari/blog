defmodule BlogWeb.WriteDraft do
    use BlogWeb, :admin_live_view
    require Logger
    require LiveMonacoEditor
    require Md
    alias Blog.Admin
    alias Blog.Admin.Draft
    alias Blog.Media
    import BlogWeb.Components.MediaPicker
    import BlogWeb.Components.MarkdownToolbar

    def mount(_params, _session, socket) do
      changeset = Admin.Draft.changeset(%Draft{}, %{})
      tags = Admin.list_tags()
      tag_options = Enum.map(tags, fn tag -> {tag.name, tag.id} end)
      
      user = socket.assigns.current_users
      media_items = Media.list_media_items(user.id)
      
      # Load categories and series
      categories = Admin.list_categories()
      category_options = build_category_options(categories)
      series = Admin.list_series(user.id)
      series_options = Enum.map(series, fn s -> {s.title, s.id} end)
      
      {:ok,
        socket
        |> assign(
          active_admin_nav: :new_post,
          page_title: "Write Draft",
          form: to_form(changeset),
          tags: tags,
          tag_options: tag_options,
          selected_tag_ids: [],
          categories: categories,
          category_options: category_options,
          series: series,
          series_options: series_options,
          show_syntax_guide: false,
          editor_value: "",
          show_media_picker: false,
          media_items: media_items,
          selected_media: nil,
          media_size: "medium",
          draft_id: nil,
          auto_save_enabled: true,
          auto_save_timer: nil,
          last_saved_at: nil,
          save_status: :idle,
          show_preview: false,
          preview_html: ""
        )
        |> push_event("init_auto_save", %{})
      }
    end

    def render(assigns) do
        ~H"""
        <div class="max-w-6xl mx-auto" id="write-draft-container">
          <!-- Page Header -->
          <div class="mb-6">
            <div class="flex items-center justify-between">
              <div>
                <h1 class="text-3xl font-bold text-neutral-850">New Post</h1>
                <p class="mt-2 text-neutral-600">Create a new blog post or save it as a draft.</p>
              </div>
              
              <!-- Auto-save Status -->
              <div class="text-sm">
                <%= case @save_status do %>
                  <% :saving -> %>
                    <span class="text-amber-600 flex items-center gap-2">
                      <svg class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      Saving...
                    </span>
                  <% :saved -> %>
                    <span class="text-green-600 flex items-center gap-2">
                      <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                      </svg>
                      Saved
                      <%= if @last_saved_at do %>
                        <span class="text-neutral-500">
                          <%= Calendar.strftime(@last_saved_at, "%I:%M %p") %>
                        </span>
                      <% end %>
                    </span>
                  <% :error -> %>
                    <span class="text-red-600">Auto-save failed</span>
                  <% _ -> %>
                    <%= if @auto_save_enabled do %>
                      <span class="text-neutral-500">Auto-save enabled</span>
                    <% else %>
                      <span class="text-neutral-400">Auto-save disabled</span>
                    <% end %>
                <% end %>
              </div>
            </div>
          </div>

          <.form for={@form} phx-submit="save-draft" phx-change="validate" class="space-y-6">
            <div class="bg-white rounded-lg shadow-sm border-2 border-chiffon-200">
              <!-- Title Section -->
              <div class="p-6 border-b border-chiffon-200">
                <.input 
                  id="title" 
                  field={@form[:title]} 
                  type="text" 
                  placeholder="Post title..." 
                  class="text-3xl font-bold border-0 focus:ring-0 p-0 w-full placeholder-neutral-400"
                />
              </div>

              <!-- Editor Section -->
              <div class="p-6">
                <div class="flex justify-between items-center mb-2">
                  <label class="block text-sm font-medium text-neutral-700">Content</label>
                  <div class="flex items-center gap-2">
                    <.media_picker 
                      show_media_picker={@show_media_picker}
                      media_items={@media_items}
                      selected_media={@selected_media}
                    />
                    <button 
                      type="button"
                      phx-click="toggle-preview"
                      class={"text-sm font-medium flex items-center gap-1 px-3 py-1 rounded-md transition-colors " <> 
                              if(@show_preview, 
                                do: "bg-sacramento-600 text-white", 
                                else: "text-sacramento-600 hover:text-sacramento-700 hover:bg-sacramento-50")}
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                      </svg>
                      Preview
                    </button>
                    <button 
                      type="button"
                      phx-click="toggle-syntax-guide"
                      class="text-sm text-sacramento-600 hover:text-sacramento-700 font-medium flex items-center gap-1"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      Markdown Syntax Guide
                    </button>
                  </div>
                </div>
                
                <%= if @form[:body].errors != [] do %>
                  <div class="mb-2">
                    <%= for error <- @form[:body].errors do %>
                      <p class="text-sm text-red-600"><%= translate_error(error) %></p>
                    <% end %>
                  </div>
                <% end %>
                
                <%= if @show_syntax_guide do %>
                  <div class="mb-4 p-4 bg-chiffon-50 border border-chiffon-200 rounded-lg">
                    <h3 class="font-semibold text-neutral-850 mb-3">Markdown Syntax Reference</h3>
                    <div class="grid md:grid-cols-2 gap-4 text-sm">
                      <div>
                        <h4 class="font-medium text-neutral-700 mb-2">Text Formatting</h4>
                        <ul class="space-y-1 text-neutral-600">
                          <li><code class="bg-white px-1 rounded">*bold*</code> or <code class="bg-white px-1 rounded">**bold**</code> → <strong>bold</strong></li>
                          <li><code class="bg-white px-1 rounded">_italic_</code> or <code class="bg-white px-1 rounded">__italic__</code> → <em>italic</em></li>
                          <li><code class="bg-white px-1 rounded">~strikethrough~</code> → <del>strikethrough</del></li>
                          <li><code class="bg-white px-1 rounded">`inline code`</code> → <code>inline code</code></li>
                        </ul>
                        
                        <h4 class="font-medium text-neutral-700 mb-2 mt-4">Headings</h4>
                        <ul class="space-y-1 text-neutral-600">
                          <li><code class="bg-white px-1 rounded">## Heading 2</code></li>
                          <li><code class="bg-white px-1 rounded">### Heading 3</code></li>
                        </ul>
                      </div>
                      
                      <div>
                        <h4 class="font-medium text-neutral-700 mb-2">Lists</h4>
                        <ul class="space-y-1 text-neutral-600">
                          <li><code class="bg-white px-1 rounded">- Unordered item</code></li>
                          <li><code class="bg-white px-1 rounded">+ Ordered item</code></li>
                        </ul>
                        
                        <h4 class="font-medium text-neutral-700 mb-2 mt-4">Other Elements</h4>
                        <ul class="space-y-1 text-neutral-600">
                          <li><code class="bg-white px-1 rounded">> Blockquote</code></li>
                          <li><code class="bg-white px-1 rounded">^superscript^</code> → <sup>superscript</sup></li>
                          <li><code class="bg-white px-1 rounded">&lt;!--comment--&gt;</code> (HTML comments)</li>
                        </ul>
                      </div>
                    </div>
                    <p class="text-xs text-neutral-500 mt-3">
                      This editor uses the <a href="https://hexdocs.pm/md" target="_blank" class="text-sacramento-600 hover:underline">md package</a> for markdown processing.
                    </p>
                  </div>
                <% end %>
                
                <div class="border border-neutral-200 rounded-lg overflow-hidden">
                  <.markdown_toolbar />
                  <LiveMonacoEditor.code_editor 
                    style="min-height: 500px" 
                    path="draft_body"
                    value={@editor_value}
                    class="w-full" 
                    change="set_editor_value" 
                    phx-debounce="300"
                    opts={
                      Map.merge(
                        LiveMonacoEditor.default_opts(),
                        %{
                          "wordWrap" => "on",
                          "theme" => "vs-light",
                          "minimap" => %{"enabled" => false},
                          "wordBasedSuggestions" => "off",
                          "fontSize" => 16,
                          "lineHeight" => 24,
                          "padding" => %{"top" => 20, "bottom" => 20}
                        }
                      )
                    }
                  />
                </div>
                
                <!-- Preview Modal -->
                <%= if @show_preview do %>
                  <div class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
                    <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
                      <!-- Background overlay -->
                      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" phx-click="toggle-preview" aria-hidden="true"></div>

                      <!-- Modal panel -->
                      <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
                      <div class="inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full sm:p-6">
                        <div>
                          <div class="flex items-center justify-between mb-4">
                            <h3 class="text-2xl font-bold text-neutral-900" id="modal-title">
                              Preview
                            </h3>
                            <button type="button" phx-click="toggle-preview" class="bg-white rounded-md text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sacramento-500">
                              <span class="sr-only">Close</span>
                              <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                              </svg>
                            </button>
                          </div>
                          <div class="mt-2 max-h-[70vh] overflow-y-auto">
                            <div class="prose prose-lg max-w-none">
                              <%= raw(@preview_html) %>
                            </div>
                          </div>
                        </div>
                        <div class="mt-5 sm:mt-6">
                          <button type="button" phx-click="toggle-preview" class="inline-flex justify-center w-full rounded-md border border-transparent shadow-sm px-4 py-2 bg-sacramento-600 text-base font-medium text-white hover:bg-sacramento-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sacramento-500 sm:text-sm">
                            Close Preview
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>

            <!-- Metadata Section -->
            <div class="bg-white rounded-lg shadow-sm p-6 border-2 border-chiffon-200">
              <h2 class="text-lg font-semibold text-neutral-850 mb-4">Post Settings</h2>
              
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Slug -->
                <div>
                  <label class="block text-sm font-medium text-neutral-700 mb-2">
                    URL Slug
                  </label>
                  <.input 
                    id="slug" 
                    field={@form[:slug]} 
                    type="text" 
                    placeholder="auto-generated-from-title" 
                    class="w-full"
                  />
                  <p class="mt-1 text-sm text-neutral-500">Leave blank to auto-generate from title</p>
                </div>

                <!-- Publish Date -->
                <div>
                  <label class="block text-sm font-medium text-neutral-700 mb-2">
                    Publish Date
                  </label>
                  <.input 
                    id="publishedDate" 
                    field={@form[:publishedDate]} 
                    type="datetime-local" 
                    class="w-full"
                  />
                  <p class="mt-1 text-sm text-neutral-500">Schedule for future or backdate</p>
                </div>
              </div>

              <!-- Category and Series -->
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
                <!-- Category -->
                <div>
                  <label class="block text-sm font-medium text-neutral-700 mb-2">
                    Category
                  </label>
                  <.input 
                    id="category_id" 
                    field={@form[:category_id]} 
                    type="select" 
                    options={[{"None", nil} | @category_options]}
                    class="w-full"
                  />
                  <p class="mt-1 text-sm text-neutral-500">Main category for this post</p>
                </div>

                <!-- Series -->
                <div>
                  <label class="block text-sm font-medium text-neutral-700 mb-2">
                    Series
                  </label>
                  <.input 
                    id="series_id" 
                    field={@form[:series_id]} 
                    type="select" 
                    options={[{"None", nil} | @series_options]}
                    class="w-full"
                  />
                  <p class="mt-1 text-sm text-neutral-500">Part of a series?</p>
                </div>
              </div>

              <!-- Tags -->
              <div class="mt-6">
                <label class="block text-sm font-medium text-neutral-700 mb-2">
                  Tags
                </label>
                <.input 
                  id="tags" 
                  field={@form[:tags]} 
                  type="select" 
                  name="tags[]" 
                  multiple 
                  options={@tag_options} 
                  value={@selected_tag_ids}
                  class="w-full"
                />
                <p class="mt-1 text-sm text-neutral-500">Select one or more tags for this post</p>
              </div>
              
              <!-- Featured Post -->
              <div class="mt-6">
                <label class="flex items-center">
                  <.input 
                    id="is_featured" 
                    field={@form[:is_featured]} 
                    type="checkbox"
                    class="mr-2"
                  />
                  <span class="text-sm font-medium text-neutral-700">Feature this post</span>
                </label>
                <p class="mt-1 text-sm text-neutral-500 ml-6">Featured posts appear prominently on the homepage</p>
              </div>
            </div>

            <!-- SEO Section -->
            <div class="bg-white rounded-lg shadow-sm p-6 border-2 border-chiffon-200">
              <h2 class="text-lg font-semibold text-neutral-850 mb-4">SEO & Social Media</h2>
              
              <!-- Meta Description -->
              <div class="mb-6">
                <label class="block text-sm font-medium text-neutral-700 mb-2">
                  Meta Description
                </label>
                <.input 
                  id="meta_description" 
                  field={@form[:meta_description]} 
                  type="textarea" 
                  rows="2"
                  placeholder="Brief description for search engines (max 160 characters)"
                  class="w-full"
                />
                <p class="mt-1 text-sm text-neutral-500">
                  <%= if @form[:meta_description].value do %>
                    <%= String.length(@form[:meta_description].value || "") %>/160 characters
                  <% else %>
                    0/160 characters
                  <% end %>
                </p>
              </div>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Meta Keywords -->
                <div>
                  <label class="block text-sm font-medium text-neutral-700 mb-2">
                    Meta Keywords
                  </label>
                  <.input 
                    id="meta_keywords" 
                    field={@form[:meta_keywords]} 
                    type="text" 
                    placeholder="keyword1, keyword2, keyword3"
                    class="w-full"
                  />
                  <p class="mt-1 text-sm text-neutral-500">Comma-separated keywords</p>
                </div>

                <!-- Twitter Card Type -->
                <div>
                  <label class="block text-sm font-medium text-neutral-700 mb-2">
                    Twitter Card Type
                  </label>
                  <.input 
                    id="twitter_card_type" 
                    field={@form[:twitter_card_type]} 
                    type="select"
                    options={[
                      {"Summary", "summary"},
                      {"Summary with Large Image", "summary_large_image"},
                      {"App", "app"},
                      {"Player", "player"}
                    ]}
                    class="w-full"
                  />
                </div>
              </div>

              <!-- Open Graph Title -->
              <div class="mt-6">
                <label class="block text-sm font-medium text-neutral-700 mb-2">
                  Open Graph Title
                </label>
                <.input 
                  id="og_title" 
                  field={@form[:og_title]} 
                  type="text" 
                  placeholder="Leave blank to use post title"
                  class="w-full"
                />
                <p class="mt-1 text-sm text-neutral-500">Title for social media sharing</p>
              </div>

              <!-- Open Graph Description -->
              <div class="mt-6">
                <label class="block text-sm font-medium text-neutral-700 mb-2">
                  Open Graph Description
                </label>
                <.input 
                  id="og_description" 
                  field={@form[:og_description]} 
                  type="textarea" 
                  rows="2"
                  placeholder="Leave blank to use meta description"
                  class="w-full"
                />
                <p class="mt-1 text-sm text-neutral-500">Description for social media sharing</p>
              </div>

              <!-- Open Graph Image -->
              <div class="mt-6">
                <label class="block text-sm font-medium text-neutral-700 mb-2">
                  Open Graph Image
                </label>
                <div class="flex gap-2">
                  <.input 
                    id="og_image" 
                    field={@form[:og_image]} 
                    type="text" 
                    placeholder="URL to image for social sharing"
                    class="flex-1"
                  />
                  <button
                    type="button"
                    phx-click="select-og-image"
                    class="px-3 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-chiffon-100"
                  >
                    Choose from Media
                  </button>
                </div>
                <p class="mt-1 text-sm text-neutral-500">Recommended size: 1200x630 pixels</p>
              </div>

              <!-- Canonical URL -->
              <div class="mt-6">
                <label class="block text-sm font-medium text-neutral-700 mb-2">
                  Canonical URL
                </label>
                <.input 
                  id="canonical_url" 
                  field={@form[:canonical_url]} 
                  type="text" 
                  placeholder="Leave blank to auto-generate"
                  class="w-full"
                />
                <p class="mt-1 text-sm text-neutral-500">The preferred URL for this content</p>
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex justify-between items-center">
              <div class="flex space-x-4">
                <.button 
                  id="save-draft-btn" 
                  name="save" 
                  value="draft" 
                  class="inline-flex items-center px-4 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-chiffon-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-lava"
                >
                  <svg class="w-5 h-5 mr-2 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V2" />
                  </svg>
                  Save as Draft
                </.button>
                
                <.button 
                  id="publish-draft-btn" 
                  name="save" 
                  value="publish" 
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-sacramento-600 hover:bg-sacramento-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sacramento-500"
                >
                  <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  Publish Now
                </.button>
              </div>

              <.link 
                navigate="/admin" 
                class="text-sm text-neutral-500 hover:text-neutral-700"
              >
                Cancel
              </.link>
            </div>
          </.form>
        </div>
        """
    end

    def handle_event("code-editor-lost-focus", %{"textBody" => body}, socket) do
      {:noreply, assign(socket, :source, body)}
    end

    def handle_event("set_editor_value", %{"value" => body}, socket) do
      socket = 
        socket
        |> assign(:editor_value, body)
        |> schedule_auto_save()
        |> update_preview_if_showing()
      
      {:noreply, socket}
    end


    def handle_event("validate", %{"draft" => draft_params}, socket) do
      # Get the editor value from socket assigns
      draft_params = Map.put(draft_params, "body", socket.assigns.editor_value || "")
      
      changeset =
        %Draft{}
        |> Admin.Draft.changeset(draft_params)
        |> Map.put(:action, :validate)
      
      {:noreply, assign(socket, form: to_form(changeset))}
    end
    
    def handle_event("validate", %{"_target" => ["live_monaco_editor", _]}, socket) do
      # ignore change events from the editor field
      {:noreply, socket}
    end

    def handle_event("toggle-syntax-guide", _, socket) do
      {:noreply, assign(socket, :show_syntax_guide, !socket.assigns.show_syntax_guide)}
    end

    def handle_event("toggle-preview", _, socket) do
      socket = 
        if !socket.assigns.show_preview do
          # Generate preview when toggling on
          preview_html = generate_preview_html(socket.assigns.editor_value)
          socket
          |> assign(:show_preview, true)
          |> assign(:preview_html, preview_html)
        else
          assign(socket, :show_preview, false)
        end
      
      {:noreply, socket}
    end

    def handle_event("toggle-media-picker", _, socket) do
      {:noreply, assign(socket, :show_media_picker, !socket.assigns.show_media_picker)}
    end

    def handle_event("close-media-picker", _, socket) do
      {:noreply, assign(socket, show_media_picker: false, selected_media: nil)}
    end

    def handle_event("select-media", %{"id" => id}, socket) do
      media = Enum.find(socket.assigns.media_items, &(&1.id == String.to_integer(id)))
      {:noreply, assign(socket, selected_media: media)}
    end

    def handle_event("update-media-size", %{"media_size" => size}, socket) do
      {:noreply, assign(socket, media_size: size)}
    end

    def handle_event("update-media-alt", params, socket) do
      # Handle both phx-blur format ({"value" => ...}) and phx-change format ({"media_alt" => ...})
      alt_text = params["media_alt"] || params["value"] || ""
      
      if socket.assigns.selected_media do
        # Update the alt text in memory for insertion
        updated_media = Map.put(socket.assigns.selected_media, :alt_text, alt_text)
        {:noreply, assign(socket, selected_media: updated_media)}
      else
        {:noreply, socket}
      end
    end

    def handle_event("insert-media", _, socket) do
      if media = socket.assigns.selected_media do
        # Determine which image path to use based on selected size
        image_path = case socket.assigns.media_size do
          "thumbnail" -> media.thumbnail_path || media.path
          "medium" -> media.medium_path || media.path
          "full" -> media.path
          _ -> media.path
        end

        # Generate markdown for the image
        alt_text = media.alt_text || media.original_filename || "Image"
        markdown = "![#{alt_text}](#{image_path})"

        # Insert at cursor position (for now, append to end)
        # In a real implementation, you'd insert at cursor position
        current_value = socket.assigns.editor_value || ""
        new_value = if current_value == "", do: markdown, else: current_value <> "\n\n" <> markdown

        # Update the editor value and close the media picker
        {:noreply,
         socket
         |> assign(editor_value: new_value)
         |> assign(show_media_picker: false)
         |> assign(selected_media: nil)
         |> LiveMonacoEditor.set_value(new_value, to: "draft_body")}
      else
        {:noreply, socket}
      end
    end

    def handle_event("save-draft", params, socket) do
      draft_params = Map.get(params, "draft", %{})
      save_action = Map.get(params, "save", "draft")
      
      # Get tag IDs from params - they come as strings
      tag_ids = Map.get(params, "tags", [])
      tag_ids = Enum.map(tag_ids, &String.to_integer/1)

      contents = %{
        "title" => Map.get(draft_params, "title", ""),
        "body" => Map.get(socket.assigns, :editor_value, ""),
        "slug" => Map.get(draft_params, "slug", ""),
        "publishedDate" => Map.get(draft_params, "publishedDate", ""),
        "tag_ids" => tag_ids,
        # SEO fields
        "meta_description" => Map.get(draft_params, "meta_description", ""),
        "meta_keywords" => Map.get(draft_params, "meta_keywords", ""),
        "og_title" => Map.get(draft_params, "og_title", ""),
        "og_description" => Map.get(draft_params, "og_description", ""),
        "og_image" => Map.get(draft_params, "og_image", ""),
        "twitter_card_type" => Map.get(draft_params, "twitter_card_type", "summary_large_image"),
        "canonical_url" => Map.get(draft_params, "canonical_url", ""),
        # Content organization fields
        "category_id" => Map.get(draft_params, "category_id"),
        "series_id" => Map.get(draft_params, "series_id"),
        "series_position" => Map.get(draft_params, "series_position"),
        "is_featured" => Map.get(draft_params, "is_featured", "false") == "true"
      }

      # First validate the changeset
      changeset = 
        %Draft{}
        |> Admin.Draft.changeset(contents)
        |> Map.put(:action, :insert)

      if changeset.valid? do
        try do
          case save_action do
            "draft" ->
              Admin.save_draft(contents)
              {:noreply, put_flash(socket, :info, "Draft Saved")}
            "publish" ->
              Admin.publish_post(contents)
              {:noreply, put_flash(socket, :info, "Post published")}
          end
        rescue
          e ->
            Logger.error("Error saving: #{inspect(e)}")
            {:noreply, put_flash(socket, :error, "Error saving: #{Exception.message(e)}")}
        end
      else
        {:noreply, assign(socket, form: to_form(changeset))}
      end
    end


    # Markdown toolbar event handler
    def handle_event("format-text", %{"format" => format}, socket) do
      # Get current editor value and cursor position
      current_value = socket.assigns.editor_value || ""
      
      # Apply formatting based on the format type
      formatted_value = case format do
        "bold" -> apply_inline_format(current_value, "**", "**")
        "italic" -> apply_inline_format(current_value, "_", "_")
        "strikethrough" -> apply_inline_format(current_value, "~", "~")
        "code" -> apply_inline_format(current_value, "`", "`")
        "heading" -> apply_line_prefix(current_value, "## ")
        "link" -> apply_link_format(current_value)
        "quote" -> apply_line_prefix(current_value, "> ")
        "unordered-list" -> apply_line_prefix(current_value, "- ")
        "ordered-list" -> apply_line_prefix(current_value, "1. ")
        "hr" -> current_value <> "\n\n---\n\n"
        "codeblock" -> apply_block_format(current_value, "```\n", "\n```")
        "table" -> apply_table_template(current_value)
        _ -> current_value
      end
      
      # Update the editor with the formatted value
      {:noreply,
       socket
       |> assign(:editor_value, formatted_value)
       |> LiveMonacoEditor.set_value(formatted_value, to: "draft_body")}
    end
    
    # Auto-save event handlers
    def handle_event("trigger_auto_save", _, socket) do
      socket = perform_auto_save(socket)
      {:noreply, socket}
    end
    
    def handle_info(:auto_save, socket) do
      socket = perform_auto_save(socket)
      {:noreply, socket}
    end
    
    # Helper functions
    defp schedule_auto_save(socket) do
      # Cancel existing timer if any
      if socket.assigns.auto_save_timer do
        Process.cancel_timer(socket.assigns.auto_save_timer)
      end
      
      # Schedule auto-save in 3 seconds
      if socket.assigns.auto_save_enabled do
        timer = Process.send_after(self(), :auto_save, 3000)
        assign(socket, :auto_save_timer, timer)
      else
        socket
      end
    end
    
    defp perform_auto_save(socket) do
      if socket.assigns.draft_id do
        # Update existing draft with auto-save
        socket
        |> assign(:save_status, :saving)
        |> auto_save_draft()
      else
        # Create new draft with auto-save
        socket
        |> assign(:save_status, :saving)
        |> create_draft_with_auto_save()
      end
    end
    
    defp auto_save_draft(socket) do
      draft_params = get_draft_params(socket)
      
      case Admin.auto_save_draft(socket.assigns.draft_id, draft_params, socket.assigns.current_users.id) do
        {:ok, _draft} ->
          socket
          |> assign(:save_status, :saved)
          |> assign(:last_saved_at, DateTime.utc_now())
          
        {:error, _changeset} ->
          assign(socket, :save_status, :error)
      end
    end
    
    defp create_draft_with_auto_save(socket) do
      draft_params = get_draft_params(socket)
      
      case Admin.create_draft_with_auto_save(draft_params, socket.assigns.current_users.id) do
        {:ok, draft} ->
          socket
          |> assign(:draft_id, draft.id)
          |> assign(:save_status, :saved)
          |> assign(:last_saved_at, DateTime.utc_now())
          
        {:error, _changeset} ->
          assign(socket, :save_status, :error)
      end
    end
    
    defp get_draft_params(socket) do
      form_data = socket.assigns.form.params
      
      # Set default publishedDate to current time if empty
      published_date = case form_data["publishedDate"] do
        nil -> DateTime.utc_now() |> DateTime.to_iso8601()
        "" -> DateTime.utc_now() |> DateTime.to_iso8601()
        date -> date
      end
      
      %{
        "title" => form_data["title"] || "",
        "body" => socket.assigns.editor_value || "",
        "slug" => form_data["slug"] || "",
        "publishedDate" => published_date,
        "meta_description" => form_data["meta_description"] || "",
        "meta_keywords" => form_data["meta_keywords"] || "",
        "og_title" => form_data["og_title"] || "",
        "og_description" => form_data["og_description"] || "",
        "og_image" => form_data["og_image"] || "",
        "twitter_card_type" => form_data["twitter_card_type"] || "summary_large_image",
        "canonical_url" => form_data["canonical_url"] || "",
        "category_id" => form_data["category_id"],
        "series_id" => form_data["series_id"],
        "series_position" => form_data["series_position"],
        "is_featured" => form_data["is_featured"] == "true"
      }
    end
    
    # Helper function to build hierarchical category options
    defp build_category_options(categories, parent_id \\ nil, prefix \\ "") do
      categories
      |> Enum.filter(fn cat -> cat.parent_id == parent_id end)
      |> Enum.flat_map(fn cat ->
        option = {prefix <> cat.name, cat.id}
        children = build_category_options(categories, cat.id, prefix <> "  ")
        [option | children]
      end)
    end
    
    # Markdown formatting helpers
    defp apply_inline_format(text, prefix, suffix) do
      # For simplicity, we'll just append the format at the end
      # In a real implementation, you'd insert at cursor position
      text <> prefix <> "text" <> suffix
    end
    
    defp apply_line_prefix(text, prefix) do
      if String.ends_with?(text, "\n") || text == "" do
        text <> prefix
      else
        text <> "\n" <> prefix
      end
    end
    
    defp apply_link_format(text) do
      text <> "[link text](https://example.com)"
    end
    
    defp apply_block_format(text, prefix, suffix) do
      if String.ends_with?(text, "\n") || text == "" do
        text <> prefix <> "\n" <> suffix
      else
        text <> "\n\n" <> prefix <> "\n" <> suffix
      end
    end
    
    defp apply_table_template(text) do
      table = """
      
      | Header 1 | Header 2 | Header 3 |
      |----------|----------|----------|
      | Cell 1   | Cell 2   | Cell 3   |
      | Cell 4   | Cell 5   | Cell 6   |
      
      """
      
      if String.ends_with?(text, "\n") || text == "" do
        text <> table
      else
        text <> "\n" <> table
      end
    end
    
    # Preview helpers
    defp update_preview_if_showing(socket) do
      if socket.assigns.show_preview do
        preview_html = generate_preview_html(socket.assigns.editor_value)
        assign(socket, :preview_html, preview_html)
      else
        socket
      end
    end
    
    defp generate_preview_html(markdown) when is_binary(markdown) do
      # The Md library returns HTML directly, not a tuple
      # It follows standard markdown rules where single newlines are ignored
      # and double newlines create paragraph breaks
      Md.generate(markdown)
    end
    
    defp generate_preview_html(_), do: ""
end
