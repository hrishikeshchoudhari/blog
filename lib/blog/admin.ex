defmodule Blog.Admin do
  @moduledoc """
  The Admin context
  """
  import Ecto.Query, warn: false
  alias Blog.Admin.Draft
  alias Blog.Repo

  def save_draft(draft_text) do
    %Draft{}
    |> Draft.changeset(draft_text)
    |> Repo.insert!()
  end

  # def draft_changeset

end