defmodule BlogWeb.ListDraft do
    use BlogWeb, :live_view
    require Logger
    require LiveMonacoEditor
    require Md
    alias Blog.Admin
    alias Blog.Admin.Draft

    def mount(_params, _session, _socket) do
      # changeset = Admin.Draft.changeset(%Draft{}, %{})
      # {:ok,
      #   assign(socket,
      #     page_title: "Write Draft",
      #     form: to_form(changeset))
      # }
    end

    def render(assigns) do
        ~H"""
        <h1>All drafts listed below</h1>
        """
    end
end
