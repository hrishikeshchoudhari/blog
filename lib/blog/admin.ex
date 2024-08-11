defmodule Blog.Admin do
  @moduledoc """
  The Admin context
  """
  import Ecto.Query, warn: false
  alias Blog.Admin.{Draft, Tag}
  alias Blog.Post
  alias Blog.Repo
  require Md
  require Logger

  def save_draft(draft_text) do
    %Draft{}
    |> Draft.changeset(draft_text)
    |> Repo.insert!()
  end

  def publish_post(post_text) do
    # html = Md.generate(post_text["body"])
    # html_text = Map.put(post_text, "body", html)

    # %Post{}
    # |> Post.changeset(html_text)
    # |> Repo.insert!()

    post_text
    |> Map.update!("body", &Md.generate/1)  # Transform the 'body' directly using `Map.update!`

    %Post{}
    |> Post.changeset(post_text)            # Create a changeset with the updated map
    |> Repo.insert!()                       # Insert the post into the database
  end

  def all_drafts() do
    # %Draft{}
    # |> Repo.all()

    Repo.all(Draft)
  end

  def save_tag(tag_content) do
    %Tag{}
    |> Tag.changeset(tag_content)
    |> Repo.insert()
  end

  def all_tags() do
    Repo.all(Tag)
  end

  def nice_work() do
    #this is a nice way to write code
  end


end
