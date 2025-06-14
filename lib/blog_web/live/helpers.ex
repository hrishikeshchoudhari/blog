defmodule BlogWeb.LiveHelpers do
  @moduledoc """
  Common helper functions for LiveViews
  """
  import Phoenix.Component
  alias Blog.Landing
  
  def assign_sidebar_data(socket) do
    socket
    |> assign(:tags, Landing.all_tags())
    |> assign(:categories, Landing.all_categories())
    |> assign(:series, Landing.all_series())
  end
end