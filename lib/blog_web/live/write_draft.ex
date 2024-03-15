defmodule BlogWeb.WriteDraft do
    use BlogWeb, :live_view
    require Logger
    require LiveMonacoEditor
    require Md
    alias Blog.Admin
    alias Blog.Admin.Draft

    def mount(_params, _session, socket) do
      # Logger.info("draft mounted")
      changeset = Admin.Draft.changeset(%Draft{}, %{})
      {:ok, assign(socket, 
                    page_title: "Write Draft",
                    form: to_form(changeset)
                  )}
    end

    def render(assigns) do
        ~H"""
        <.form for={@form} phx-submit="save-draft">
        <.input id="title" field={@form[:title]} type="text" value="" placeholder="Enter title here" class="mb-10 pb-10"/>
        <LiveMonacoEditor.code_editor id="body" class="mt-10"
          opts={
            Map.merge(
              LiveMonacoEditor.default_opts(),
              %{
                "wordWrap" => "on",
                "theme" => "vs-dark",
                "minimap" => %{"enabled" => true},
                "wordBasedSuggestions" => "off"
              }
            )
          }
        />
        <.button id="save-draft-btn" name="save" value="draft" class="mt-10 bg-neutral-800 ">Save Draft</.button>
        <.button id="publish-draft-btn" name="save" value="publish" class="mt-10 bg-lime-200 hover:bg-lime-300 text-black border-2 border-lime-800">Publish</.button>
        </.form>
        """
    end

    def handle_event("code-editor-lost-focus", %{"textBody" => body}, socket) do
      {:noreply, assign(socket, :source, body)}
    end

    def handle_event("save-draft", params, socket) do
      contents = %{
        "title" => params["draft"]["title"],
        "body" => params["live_monaco_editor"]["file"]
      }

      if params["save"] == "draft" do
        Admin.save_draft(contents)
        |> Logger.info()
        {:noreply, socket}       
      else
        Admin.publish_post(contents)
        |> Logger.info()
        {:noreply, socket }
      end

    end

    # plan the route's layout properly
    # sidebar
    # draft section - title, body, tags, etc
    # save draft btn, publish btn
    # 
end