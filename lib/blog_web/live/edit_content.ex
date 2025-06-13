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

  def mount(%{"id" => id}, _session, socket) do
    type = case socket.assigns.live_action do
      :edit_post -> "post"
      :edit_draft -> "draft"
    end
    
    {content, page_title} = case type do
      "post" ->
        post = Admin.get_post!(id)
        {"Post", post}
        
      "draft" ->
        draft = Admin.get_draft!(id)
        {"Draft", draft}
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
        page_title: "Edit #{page_title} - #{content.title}",
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
        media_size: "medium")
    }
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto" id="edit-content-container" phx-hook="MonacoUpdater">
      <!-- Page Header -->
      <div class="mb-6">
        <h1 class="text-3xl font-bold text-neutral-850">Edit <%= String.capitalize(@content_type) %></h1>
        <p class="mt-2 text-neutral-600">Update your <%= @content_type %>.</p>
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
        </div>

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
    {:noreply, assign(socket, :editor_value, body)}
  end

  def handle_event("validate", %{"post" => content_params}, socket) when socket.assigns.content_type == "post" do
    content_params = Map.put(content_params, "body", socket.assigns.editor_value || "")
    
    changeset =
      socket.assigns.content
      |> Post.changeset(content_params)
      |> Map.put(:action, :validate)
    
    {:noreply, assign(socket, form: to_form(changeset))}
  end
  
  def handle_event("validate", %{"draft" => content_params}, socket) when socket.assigns.content_type == "draft" do
    content_params = Map.put(content_params, "body", socket.assigns.editor_value || "")
    
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
      "tag_ids" => tag_ids
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
      "tag_ids" => Enum.map(draft.tags, & &1.id)
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

  defp format_datetime_local(nil), do: ""
  defp format_datetime_local(datetime) do
    datetime
    |> DateTime.shift_zone!("Etc/UTC")
    |> Calendar.strftime("%Y-%m-%dT%H:%M")
  end
end