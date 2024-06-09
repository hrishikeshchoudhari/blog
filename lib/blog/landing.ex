defmodule Blog.Landing do
  @moduledoc """
  The Landing context
  """
  import Ecto.Query, warn: false
  alias Blog.Post
  alias Blog.Repo
  require Logger

  def all_posts() do
    Repo.all(Post)
  end

  def about() do
    {}
  end
end
