defmodule BlogWeb.AdminHome do
    use BlogWeb, :admin_live_view
    require Logger
    alias Blog.Admin

    def mount(_params, _session, socket) do
      {:ok, assign(socket, drafts: [])}
    end

    def render(assigns) do
        ~H"""
        <h3> Welcome to the admin area </h3>
        <div id="view_drafts">
          <.button id="view_drafts_btn" name="view_draft" value="view_draft" phx-click="view_draft">View Drafts</.button>
        </div>

        <div id="view_posts">
          <.button id="view_posts_btn" name="view_posts" value="view_posts" phx-click="view_posts">View Posts</.button>
        </div>

        <div id="new_draft">
          <.button id="new_draft_btn" name="new_draft" value="new_draft">Write New Draft</.button>
        </div>

        <div id="drafts_list">
          <%= if @drafts do %>
            <ul>
              <%= for draft <- @drafts do %>
                <li><%= draft.title %> - <%= draft.body %></li>
              <% end %>
            </ul>
          <% end %>
        </div>
        """
    end

    def handle_event("view_draft", _unsigned_params, socket) do
      drafts = Admin.all_drafts()  # Fetch all drafts
      {:noreply, assign(socket, drafts: drafts)}
    end

end
