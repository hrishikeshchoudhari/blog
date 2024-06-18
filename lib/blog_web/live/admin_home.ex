defmodule BlogWeb.AdminHome do
    use BlogWeb, :admin_live_view
    require Logger
    alias Blog.Admin

    def mount(_params, _session, socket) do
      {:ok, socket}
    end

    def render(assigns) do
        ~H"""
        <h3> Welcome to the admin area </h3>
        <div id="view_drafts">
          <.button id="view_drafts_btn" name="view_drafts" value="view_drafts">View Drafts</.button>
        </div>

        <div id="new_draft">
          <.button id="new_draft_btn" name="new_draft" value="new_draft">Write New Draft</.button>
        </div>
        """
    end

end
