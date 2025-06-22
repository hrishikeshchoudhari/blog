defmodule BlogWeb.EditContent do
  use BlogWeb, :admin_live_view
  require Logger
  require LiveMonacoEditor
  require Md
  alias Blog.Admin
  alias Blog.Post
  alias Blog.Admin.Draft
  alias Blog.Media
  import BlogWeb.Components.MediaPicker
  import BlogWeb.Components.MarkdownToolbar

  def mount(%{"id" => id}, _session, socket) do
    type = case socket.assigns.live_action do
      :edit_post -> "post"
      :edit_draft -> "draft"
    end
    
    content = case type do
      "post" ->
        Admin.get_post!(id)
        
      "draft" ->
        Admin.get_draft!(id)
    end
    
    changeset = case type do
      "post" -> Post.changeset(content, %{})
      "draft" -> Draft.changeset(content, %{})
    end
    
    tags = Admin.list_tags()
    tag_options = Enum.map(tags, fn tag -> {tag.name, tag.id} end)
    selected_tag_ids = Enum.map(content.tags, & &1.id)
    
    # Use raw_body if available, otherwise fall back to body
    editor_value = content.raw_body || content.body
    editing_html = is_nil(content.raw_body)
    
    user = socket.assigns.current_users
    media_items = Media.list_media_items(user.id)
    
    {:ok,
      assign(socket,
        active_admin_nav: if(type == "post", do: :posts, else: :dashboard),
        page_title: "Edit #{String.capitalize(type)} - #{content.title}",
        content: content,
        content_type: type,
        form: to_form(changeset),
        tags: tags,
        tag_options: tag_options,
        selected_tag_ids: selected_tag_ids,
        editor_value: editor_value,
        editing_html: editing_html,
        show_syntax_guide: false,
        show_media_picker: false,
        media_items: media_items,
        selected_media: nil,
        media_size: "medium",
        auto_save_enabled: type == "draft",
        auto_save_timer: nil,
        last_saved_at: nil,
        save_status: :idle,
        show_preview: false,
        preview_html: "")
    }
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto" id="edit-content-container" phx-hook="MonacoUpdater">
      <!-- Page Header -->
      <div class="mb-6">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-neutral-850">Edit <%= String.capitalize(@content_type) %></h1>
            <p class="mt-2 text-neutral-600">Update your <%= @content_type %>.</p>
          </div>
          <div class="flex items-center gap-4">
            <!-- Auto-save Status -->
            <%= if @content_type == "draft" do %>
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
            <% end %>
            
            <%= if @content_type == "draft" do %>
              <.link 
                navigate={"/admin/draft/#{@content.id}/revisions"} 
                class="inline-flex items-center px-4 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-chiffon-100"
              >
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                View Version History
              </.link>
            <% end %>
          </div>
        </div>
      </div>

      <.form for={@form} phx-submit="update-content" phx-change="validate" class="space-y-6">
        <div class="bg-white rounded-lg shadow-sm border-2 border-chiffon-200">
          <!-- Title Section -->
          <div class="p-6 border-b border-chiffon-200">
            <.input 
              id="title" 
              field={@form[:title]} 
              type="text" 
              value={@content.title}
              placeholder="Post title..." 
              class="text-3xl font-bold border-0 focus:ring-0 p-0 w-full placeholder-neutral-400"
            />
          </div>

          <!-- Editor Section -->
          <div class="p-6">
            <div class="flex justify-between items-center mb-2">
              <label class="block text-sm font-medium text-neutral-700">Content</label>
              <%= if !@editing_html do %>
                <div class="flex items-center gap-2">
                  <.media_picker 
                    show_media_picker={@show_media_picker}
                    media_items={@media_items}
                    selected_media={@selected_media}
                  />
                  <button 
                    type="button"
                    phx-click="toggle-preview"
                    class={"text-sm font-medium flex items-center gap-1 " <> if(@show_preview, do: "text-sacramento-700", else: "text-sacramento-600 hover:text-sacramento-700")}
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                    <%= if @show_preview, do: "Hide Preview", else: "Preview" %>
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
              <% end %>
            </div>
            
            <%= if @form[:body].errors != [] do %>
              <div class="mb-2">
                <%= for error <- @form[:body].errors do %>
                  <p class="text-sm text-red-600"><%= translate_error(error) %></p>
                <% end %>
              </div>
            <% end %>
            
            <%= if @editing_html do %>
              <div class="mb-3 p-3 bg-amber-50 border border-amber-200 rounded-lg">
                <p class="text-sm text-amber-800">
                  <strong>Note:</strong> This <%= @content_type %> was created before raw markdown storage was available. 
                  You're editing the HTML directly. Be careful with formatting.
                </p>
              </div>
            <% end %>
            
            <%= if @show_syntax_guide && !@editing_html do %>
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
              <%= if !@editing_html do %>
                <.markdown_toolbar />
              <% end %>
              <LiveMonacoEditor.code_editor 
                style="min-height: 500px" 
                id="body" 
                class="w-full" 
                value={@editor_value}
                change="set_editor_value" 
                phx-debounce="1000"
                opts={
                  Map.merge(
                    LiveMonacoEditor.default_opts(),
                    %{
                      "language" => if(@editing_html, do: "html", else: "markdown"),
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
        </div>

        <!-- Metadata Section -->
        <div class="bg-white rounded-lg shadow-sm p-6 border-2 border-chiffon-200">
          <h2 class="text-lg font-semibold text-neutral-850 mb-4"><%= String.capitalize(@content_type) %> Settings</h2>
          
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
                value={@content.slug}
                placeholder="auto-generated-from-title" 
                class="w-full"
              />
              <p class="mt-1 text-sm text-neutral-500">
                <%= if @content_type == "post" do %>
                  Changing the slug will break existing links
                <% else %>
                  Leave blank to auto-generate from title
                <% end %>
              </p>
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
                value={format_datetime_local(@content.publishedDate)}
                class="w-full"
              />
              <p class="mt-1 text-sm text-neutral-500">When this should be published</p>
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
            <p class="mt-1 text-sm text-neutral-500">Select one or more tags for this <%= @content_type %></p>
          </div>
          
          <!-- Post Type -->
          <div class="mt-6">
            <label class="block text-sm font-medium text-neutral-700 mb-2">
              Content Type
            </label>
            <div class="flex space-x-4">
              <label class="inline-flex items-center">
                <input type="radio" name="post_type" value="post" checked={@form[:post_type].value == "post" || @form[:post_type].value == nil} phx-change="validate" class="form-radio text-sacramento-600" />
                <span class="ml-2">Blog Post</span>
              </label>
              <label class="inline-flex items-center">
                <input type="radio" name="post_type" value="project" checked={@form[:post_type].value == "project"} phx-change="validate" class="form-radio text-sacramento-600" />
                <span class="ml-2">Project</span>
              </label>
              <label class="inline-flex items-center">
                <input type="radio" name="post_type" value="reading" checked={@form[:post_type].value == "reading"} phx-change="validate" class="form-radio text-sacramento-600" />
                <span class="ml-2">Book Review</span>
              </label>
            </div>
          </div>
        </div>
        
        <!-- Type-specific fields -->
        <%= if @form[:post_type].value == "project" do %>
          <div class="mt-6 p-4 bg-chiffon-50 rounded-lg border border-chiffon-200">
            <h3 class="text-sm font-semibold text-neutral-850 mb-4">Project Details</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-neutral-700 mb-1">Demo URL</label>
                <.input 
                  field={@form[:demo_url]} 
                  type="text" 
                  placeholder="https://example.com/demo"
                  class="w-full"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-neutral-700 mb-1">GitHub URL</label>
                <.input 
                  field={@form[:github_url]} 
                  type="text" 
                  placeholder="https://github.com/user/repo"
                  class="w-full"
                />
              </div>
              <div class="md:col-span-2">
                <label class="block text-sm font-medium text-neutral-700 mb-1">Tech Stack</label>
                <.input 
                  field={@form[:tech_stack]} 
                  type="text" 
                  placeholder="Elixir, Phoenix, PostgreSQL"
                  class="w-full"
                />
                <p class="mt-1 text-xs text-neutral-500">Enter technologies separated by commas</p>
              </div>
            </div>
          </div>
        <% end %>
        
        <%= if @form[:post_type].value == "reading" do %>
          <div class="mt-6 p-4 bg-chiffon-50 rounded-lg border border-chiffon-200">
            <h3 class="text-sm font-semibold text-neutral-850 mb-4">Book Details</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-neutral-700 mb-1">Author</label>
                <.input 
                  field={@form[:author]} 
                  type="text" 
                  placeholder="Author name"
                  class="w-full"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-neutral-700 mb-1">ISBN</label>
                <.input 
                  field={@form[:isbn]} 
                  type="text" 
                  placeholder="978-3-16-148410-0"
                  class="w-full"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-neutral-700 mb-1">Rating</label>
                <.input 
                  field={@form[:rating]} 
                  type="select" 
                  options={[
                    {"⭐ 1 Star", "1"},
                    {"⭐⭐ 2 Stars", "2"},
                    {"⭐⭐⭐ 3 Stars", "3"},
                    {"⭐⭐⭐⭐ 4 Stars", "4"},
                    {"⭐⭐⭐⭐⭐ 5 Stars", "5"}
                  ]}
                  class="w-full"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-neutral-700 mb-1">Date Read</label>
                <.input 
                  field={@form[:date_read]} 
                  type="date" 
                  class="w-full"
                />
              </div>
            </div>
          </div>
        <% end %>

        <!-- Action Buttons -->
        <div class="flex justify-between items-center">
          <div class="flex space-x-4">
            <.button 
              id="update-content-btn" 
              type="submit"
              class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-sacramento-600 hover:bg-sacramento-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sacramento-500"
            >
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              Update <%= String.capitalize(@content_type) %>
            </.button>

            <%= if @content_type == "draft" do %>
              <.button 
                id="publish-btn" 
                type="button"
                phx-click="publish"
                class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-lava hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500"
              >
                <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Publish Now
              </.button>
            <% end %>
          </div>

          <.link 
            navigate={if @content_type == "post", do: "/admin/posts", else: "/admin"} 
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
      |> update_preview_if_showing()
      |> schedule_auto_save()
    
    {:noreply, socket}
  end

  def handle_event("validate", params, socket) when socket.assigns.content_type == "post" do
    content_params = Map.get(params, "post", %{})
    content_params = Map.put(content_params, "body", socket.assigns.editor_value || "")
    content_params = Map.put(content_params, "post_type", Map.get(params, "post_type", socket.assigns.content.post_type || "post"))
    
    changeset =
      socket.assigns.content
      |> Post.changeset(content_params)
      |> Map.put(:action, :validate)
    
    {:noreply, assign(socket, form: to_form(changeset))}
  end
  
  def handle_event("validate", params, socket) when socket.assigns.content_type == "draft" do
    content_params = Map.get(params, "draft", %{})
    content_params = Map.put(content_params, "body", socket.assigns.editor_value || "")
    content_params = Map.put(content_params, "post_type", Map.get(params, "post_type", socket.assigns.content.post_type || "post"))
    
    changeset =
      socket.assigns.content
      |> Draft.changeset(content_params)
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
      socket
      |> assign(:show_preview, !socket.assigns.show_preview)
      |> update_preview_if_showing()
    
    {:noreply, socket}
  end

  def handle_event("update-content", params, socket) do
    content_params = Map.get(params, socket.assigns.content_type, %{})
    
    # Get tag IDs from params - they come as strings
    tag_ids = Map.get(params, "tags", [])
    tag_ids = Enum.map(tag_ids, &String.to_integer/1)

    contents = %{
      "title" => Map.get(content_params, "title", ""),
      "body" => Map.get(socket.assigns, :editor_value, ""),
      "slug" => Map.get(content_params, "slug", ""),
      "publishedDate" => Map.get(content_params, "publishedDate", ""),
      "tag_ids" => tag_ids,
      "post_type" => Map.get(params, "post_type", "post"),
      "author" => Map.get(content_params, "author", ""),
      "isbn" => Map.get(content_params, "isbn", ""),
      "rating" => Map.get(content_params, "rating", ""),
      "date_read" => Map.get(content_params, "date_read", ""),
      "demo_url" => Map.get(content_params, "demo_url", ""),
      "github_url" => Map.get(content_params, "github_url", ""),
      "tech_stack" => Map.get(content_params, "tech_stack", "")
    }

    # First validate the changeset
    changeset = case socket.assigns.content_type do
      "post" -> Post.changeset(socket.assigns.content, contents)
      "draft" -> Draft.changeset(socket.assigns.content, contents)
    end
    |> Map.put(:action, :update)

    if changeset.valid? do
      try do
        result = case socket.assigns.content_type do
          "post" -> Admin.update_post(socket.assigns.content, contents)
          "draft" -> Admin.update_draft(socket.assigns.content, contents)
        end
        
        case result do
          {:ok, _updated_content} ->
            destination = if socket.assigns.content_type == "post", do: "/admin/posts", else: "/admin"
            {:noreply, 
              socket
              |> put_flash(:info, "#{String.capitalize(socket.assigns.content_type)} updated successfully")
              |> push_navigate(to: destination)}
          {:error, changeset} ->
            {:noreply, 
              socket
              |> assign(form: to_form(changeset))}
        end
      rescue
        e ->
          Logger.error("Error updating content: #{inspect(e)}")
          {:noreply, put_flash(socket, :error, "Error updating #{socket.assigns.content_type}: #{Exception.message(e)}")}
      end
    else
      {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("publish", _, socket) do
    # Convert draft to post
    draft = socket.assigns.content
    
    post_params = %{
      "title" => draft.title,
      "body" => draft.raw_body || draft.body,
      "slug" => draft.slug,
      "publishedDate" => draft.publishedDate || DateTime.utc_now(),
      "tag_ids" => Enum.map(draft.tags, & &1.id),
      "post_type" => draft.post_type || "post",
      "author" => draft.author,
      "isbn" => draft.isbn,
      "rating" => draft.rating,
      "date_read" => draft.date_read,
      "demo_url" => draft.demo_url,
      "github_url" => draft.github_url,
      "tech_stack" => draft.tech_stack
    }
    
    try do
      Admin.publish_post(post_params)
      # TODO: Optionally delete the draft after publishing
      
      {:noreply, 
        socket
        |> put_flash(:info, "Draft published successfully!")
        |> push_navigate(to: "/admin/posts")}
    rescue
      e ->
        Logger.error("Error publishing draft: #{inspect(e)}")
        {:noreply, put_flash(socket, :error, "Error publishing draft: #{Exception.message(e)}")}
    end
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

  # Markdown toolbar event handler
  def handle_event("format-text", %{"format" => format}, socket) do
    # Get current editor value
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
     |> push_event("update-monaco-editor", %{value: formatted_value})}
  end

  defp format_datetime_local(nil), do: ""
  defp format_datetime_local(datetime) do
    datetime
    |> DateTime.shift_zone!("Etc/UTC")
    |> Calendar.strftime("%Y-%m-%dT%H:%M")
  end
  
  # Auto-save functionality
  defp schedule_auto_save(socket) do
    if socket.assigns.auto_save_enabled do
      # Cancel existing timer if any
      if socket.assigns.auto_save_timer do
        Process.cancel_timer(socket.assigns.auto_save_timer)
      end
      
      # Schedule auto-save in 3 seconds
      timer = Process.send_after(self(), :auto_save, 3000)
      assign(socket, :auto_save_timer, timer)
    else
      socket
    end
  end
  
  def handle_info(:auto_save, socket) do
    socket = perform_auto_save(socket)
    {:noreply, socket}
  end
  
  defp perform_auto_save(socket) do
    if socket.assigns.content_type == "draft" do
      socket
      |> assign(:save_status, :saving)
      |> auto_save_draft()
    else
      socket
    end
  end
  
  defp auto_save_draft(socket) do
    draft_params = get_draft_params(socket)
    
    case Admin.auto_save_draft(socket.assigns.content.id, draft_params, socket.assigns.current_users.id) do
      {:ok, _draft} ->
        socket
        |> assign(:save_status, :saved)
        |> assign(:last_saved_at, DateTime.utc_now())
        
      {:error, _changeset} ->
        assign(socket, :save_status, :error)
    end
  end
  
  defp get_draft_params(socket) do
    form_data = socket.assigns.form.params
    
    # Set default publishedDate if empty
    published_date = case form_data["publishedDate"] do
      nil -> 
        socket.assigns.content.publishedDate || DateTime.utc_now()
        |> format_datetime_local()
      "" -> 
        socket.assigns.content.publishedDate || DateTime.utc_now()
        |> format_datetime_local()
      date -> date
    end
    
    %{
      "title" => form_data["title"] || socket.assigns.content.title || "",
      "body" => socket.assigns.editor_value || "",
      "slug" => form_data["slug"] || socket.assigns.content.slug || "",
      "publishedDate" => published_date
    }
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
  
  defp update_preview_if_showing(socket) do
    if socket.assigns.show_preview && !socket.assigns.editing_html do
      preview_html = generate_preview_html(socket.assigns.editor_value || "")
      assign(socket, :preview_html, preview_html)
    else
      socket
    end
  end
  
  defp generate_preview_html(markdown_content) when is_binary(markdown_content) do
    # The Md library returns HTML directly, not a tuple
    # It follows standard markdown rules where single newlines are ignored
    # and double newlines create paragraph breaks
    Md.generate(markdown_content)
  end
  
  defp generate_preview_html(_), do: ""
end