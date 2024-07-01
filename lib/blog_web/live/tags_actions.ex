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
          page_title: "All Tags Stuff",
          form: to_form(changeset))
      }
    end

    def render(assigns) do
      ~H"""
        <h1>All Tags Worked On Here</h1>
        <.form for={@form} phx-submit="save-tag">
          <.input id="name" field={@form[:name]} type="text" value="" placeholder="What is the tag's string" class="mb-10 pb-10"/>
          <.input id="slug" field={@form[:slug]} type="text" value="" placeholder="What is the slug for this tag" class="mb-10 pb-10"/>
          <.input id="description" field={@form[:description]} type="text" value="" errors={} placeholder="Some descriptive text" class="mb-10 pb-10"/>
          <.button id="save-tag-btn" class="mt-10 bg-neutral-800 ">Save Tag</.button>
        </.form>
        <br/>
        <h1>All Tags</h1>
        <ul>
          <%= for tag <- @tags do %>
          <li><%= tag.name %> -- <%= tag.slug %> -- <%= tag.description %></li>
          <% end %>
        </ul>
      """
    end

    def handle_event("save-tag", %{"tag" => tag_params}, socket) do
      case Admin.save_tag(tag_params) do
        {:ok, tag} ->
          socket =
            socket
            |> update(:tags, fn tags -> [tag | tags] end )
            |> put_flash(:info, "Tag saved successfully!")
            |> assign(:form, to_form(Admin.Tag.changeset(%Tag{}, %{})))

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
