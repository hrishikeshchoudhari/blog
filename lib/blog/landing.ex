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

  def get_post_by_slug(slug) do
    Repo.get_by(Post, slug: slug)
  end

  def about() do
    {}
  end
end
