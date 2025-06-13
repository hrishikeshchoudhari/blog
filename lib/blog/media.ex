defmodule Blog.Media do
  @moduledoc """
  The Media context for managing uploaded images and files
  """
  import Ecto.Query, warn: false
  alias Blog.Repo
  alias Blog.Media.MediaItem

  @doc """
  Returns the list of media items for a user
  """
  def list_media_items(user_id) do
    MediaItem
    |> where(user_id: ^user_id)
    |> order_by([desc: :inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets a single media item
  """
  def get_media_item!(id, user_id) do
    MediaItem
    |> where(id: ^id, user_id: ^user_id)
    |> Repo.one!()
  end

  @doc """
  Creates a media item with image processing
  """
  def create_media_item(attrs \\ %{}, user_id) do
    # Convert all keys to strings to avoid mixed keys error
    attrs = 
      attrs
      |> Map.new(fn {k, v} -> {to_string(k), v} end)
      |> Map.put("user_id", user_id)
    
    %MediaItem{}
    |> MediaItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a media item (mainly for alt text and caption)
  """
  def update_media_item(%MediaItem{} = media_item, attrs) do
    media_item
    |> MediaItem.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a media item and its files
  """
  def delete_media_item(%MediaItem{} = media_item) do
    # Delete physical files
    delete_media_files(media_item)
    
    # Delete database record
    Repo.delete(media_item)
  end

  defp delete_media_files(media_item) do
    base_path = Path.join([:code.priv_dir(:blog), "static"])
    
    # Delete original
    if media_item.path do
      File.rm(Path.join(base_path, media_item.path))
    end
    
    # Delete thumbnail
    if media_item.thumbnail_path do
      File.rm(Path.join(base_path, media_item.thumbnail_path))
    end
    
    # Delete medium size
    if media_item.medium_path do
      File.rm(Path.join(base_path, media_item.medium_path))
    end
  end

  @doc """
  Process uploaded image and create thumbnails
  """
  def process_upload(upload_entry, user_id) do
    # Generate unique filename
    uuid = Ecto.UUID.generate()
    ext = Path.extname(upload_entry.client_name)
    filename = "#{uuid}#{ext}"
    
    # Create upload directories
    upload_dir = Path.join([:code.priv_dir(:blog), "static", "uploads", "images"])
    thumb_dir = Path.join(upload_dir, "thumbnails")
    medium_dir = Path.join(upload_dir, "medium")
    
    File.mkdir_p!(upload_dir)
    File.mkdir_p!(thumb_dir)
    File.mkdir_p!(medium_dir)
    
    # Define paths
    dest_path = Path.join(upload_dir, filename)
    thumb_path = Path.join(thumb_dir, filename)
    medium_path = Path.join(medium_dir, filename)
    
    # Copy original file
    File.cp!(upload_entry.path, dest_path)
    
    # Get image dimensions
    {width, height} = get_image_dimensions(dest_path)
    
    # Create thumbnails (requires ImageMagick)
    create_thumbnail(dest_path, thumb_path, 300)
    create_medium_size(dest_path, medium_path, 800)
    
    # Create media item record
    attrs = %{
      filename: filename,
      original_filename: upload_entry.client_name,
      content_type: upload_entry.client_type,
      size: upload_entry.client_size,
      width: width,
      height: height,
      path: "/uploads/images/#{filename}",
      thumbnail_path: "/uploads/images/thumbnails/#{filename}",
      medium_path: "/uploads/images/medium/#{filename}"
    }
    
    create_media_item(attrs, user_id)
  end

  defp get_image_dimensions(path) do
    case System.cmd("identify", ["-format", "%wx%h", path]) do
      {dimensions, 0} ->
        [width, height] = String.split(String.trim(dimensions), "x")
        {String.to_integer(width), String.to_integer(height)}
      _ ->
        {nil, nil}
    end
  end

  defp create_thumbnail(source, dest, size) do
    System.cmd("convert", [
      source,
      "-thumbnail",
      "#{size}x#{size}>",
      "-quality",
      "85",
      dest
    ])
  end

  defp create_medium_size(source, dest, size) do
    System.cmd("convert", [
      source,
      "-resize",
      "#{size}x#{size}>",
      "-quality",
      "90",
      dest
    ])
  end
end