defmodule Mix.Tasks.Blog.SetupAdmin do
  @moduledoc """
  Creates the initial admin user for the blog.
  
  Usage:
    mix blog.setup_admin email@example.com password123456
  """
  
  use Mix.Task
  alias Blog.Accounts
  
  @shortdoc "Creates the initial admin user"
  
  def run([email, password]) do
    Mix.Task.run("app.start")
    
    case Accounts.has_any_users?() do
      true ->
        Mix.shell().error("An admin user already exists!")
        
      false ->
        case Accounts.register_users(%{email: email, password: password}) do
          {:ok, user} ->
            # Auto-confirm the admin user
            {:ok, _} = Accounts.Users
            |> Blog.Repo.get!(user.id)
            |> Ecto.Changeset.change(confirmed_at: DateTime.utc_now())
            |> Blog.Repo.update()
            
            Mix.shell().info("Admin user created successfully!")
            Mix.shell().info("Email: #{email}")
            Mix.shell().info("You can now log in with these credentials.")
            
          {:error, changeset} ->
            Mix.shell().error("Failed to create admin user:")
            Enum.each(changeset.errors, fn {field, {msg, _}} ->
              Mix.shell().error("  #{field}: #{msg}")
            end)
        end
    end
  end
  
  def run(_) do
    Mix.shell().error("Usage: mix blog.setup_admin email@example.com password123456")
  end
end