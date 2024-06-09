defmodule BlogWeb.WriteDraft do
    use BlogWeb, :live_view
    require Logger
    require LiveMonacoEditor
    require Md
    alias Blog.Admin
    alias Blog.Admin.Draft

    def mount(_params, _session, socket) do
      changeset = Admin.Draft.changeset(%Draft{}, %{})
      {:ok,
        assign(socket,
          page_title: "Write Draft",
          form: to_form(changeset),
          active_nav: :writing
        )
      }
    end

    def render(assigns) do
        ~H"""
        <.form for={@form} phx-submit="save-draft">
          <.input id="title" field={@form[:title]} type="text" value="" placeholder="Enter title here" class="mb-10 pb-10"/>
          <LiveMonacoEditor.code_editor style="min-height: 600px" id="body" class="mt-10 resize" change="set_editor_value" phx-debounce="1000"
            opts={
              Map.merge(
                LiveMonacoEditor.default_opts(),
                %{
                  "wordWrap" => "on",
                  "theme" => "vs-light",
                  "minimap" => %{"enabled" => true},
                  "wordBasedSuggestions" => "off"
                }
              )
            }
          />
          <.input id="slug" field={@form[:slug]} type="text" value="" placeholder="Slug will be generated" class="mb-10 pb-10"/>
          <.input id="publishedDate" field={@form[:publishedDate]} type="datetime-local" value="" class="mb-10 pb-10"/>
          <.button id="save-draft-btn" name="save" value="draft" class="mt-10 bg-neutral-800 ">Save Draft</.button>
          <.button id="publish-draft-btn" name="save" value="publish" class="mt-10 bg-lime-200 hover:bg-lime-300 text-black border-2 border-lime-800">Publish</.button>
        </.form>
        """
    end

    def handle_event("code-editor-lost-focus", %{"textBody" => body}, socket) do
      {:noreply, assign(socket, :source, body)}
    end

    def handle_event("set_editor_value", %{"value" => body}, socket) do
      {:noreply, assign(socket, :editor_value, body)}
    end


    def handle_event("validate", %{"_target" => ["live_monaco_editor", "my_file.html"]}, socket) do
      # ignore change events from the editor field
      {:noreply, socket}
    end

    def handle_event("save-draft",
      %{
        "draft" => %{"title" => title, "slug" => slug, "publishedDate" => publishedDate},
        "live_monaco_editor" => %{"file" => _body},
        "save" => save_action
      } = _params,
      socket) do

      Logger.info(socket)

      contents = %{
        "title" => title,
        "body" => socket.assigns.editor_value,
        "slug" => slug,
        "publishedDate" => publishedDate
      }

      action_result =
        case save_action do
          "draft" ->
            Admin.save_draft(contents)
          "publish" ->
            Admin.publish_post(contents)
        end

      Logger.info(action_result)

      {:noreply, socket}
    end


    # plan the route's layout properly
    # sidebar
    # draft section - title, body, tags, etc
    # save draft btn, publish btn
    #
end
