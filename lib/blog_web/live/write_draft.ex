defmodule BlogWeb.WriteDraft do
    use BlogWeb, :admin_live_view
    require Logger
    require LiveMonacoEditor
    require Md
    alias Blog.Admin
    alias Blog.Admin.Draft
    alias Blog.Media
    import BlogWeb.Components.MediaPicker

    def mount(_params, _session, socket) do
      changeset = Admin.Draft.changeset(%Draft{}, %{})
      tags = Admin.list_tags()
      tag_options = Enum.map(tags, fn tag -> {tag.name, tag.id} end)
      
      user = socket.assigns.current_users
      media_items = Media.list_media_items(user.id)
      
      {:ok,
        assign(socket,
          active_admin_nav: :new_post,
          page_title: "Write Draft",
          form: to_form(changeset),
          tags: tags,
          tag_options: tag_options,
          selected_tag_ids: [],
          show_syntax_guide: false,
          editor_value: "",
          show_media_picker: false,
          media_items: media_items,
          selected_media: nil,
          media_size: "medium")
      }
    end

    def render(assigns) do
        ~H"""
        <div class="max-w-6xl mx-auto" id="write-draft-container" phx-hook="MonacoUpdater">
          <!-- Page Header -->
          <div class="mb-6">
            <h1 class="text-3xl font-bold text-neutral-850">New Post</h1>
            <p class="mt-2 text-neutral-600">Create a new blog post or save it as a draft.</p>
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
                  <LiveMonacoEditor.code_editor 
                    style="min-height: 500px" 
                    id="body" 
                    class="w-full" 
                    change="set_editor_value" 
                    phx-debounce="1000"
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
      {:noreply, assign(socket, :editor_value, body)}
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
         |> push_event("update-monaco-editor", %{value: new_value})}
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
        "tag_ids" => tag_ids
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


    # plan the route's layout properly
    # sidebar
    # draft section - title, body, tags, etc
    # save draft btn, publish btn
    #
end
