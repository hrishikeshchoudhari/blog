defmodule BlogWeb.Layouts do
  use BlogWeb, :html
  require Logger

  def is_active(place, path) do
    Logger.info(place)
    if place == path, do: "border-b-8 border-lava rounded opacity-100", else: "opacity-75 hover:opacity-85 border-b-8 border-transparent hover:border-lava hover:rounded"
  end

  embed_templates "layouts/*"
end
