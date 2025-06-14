defmodule BlogWeb.AdminCategories do
  use BlogWeb, :admin_live_view
  alias Blog.Admin
  alias Blog.Admin.Category

  def mount(_params, _session, socket) do
    categories = Admin.list_categories()
    changeset = Category.changeset(%Category{}, %{})
    
    {:ok,
     socket
     |> assign(
       categories: categories,
       page_title: "Manage Categories",
       active_admin_nav: :categories,
       form: to_form(changeset),
       editing_category: nil
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto">
      <!-- Page Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-neutral-850">Categories</h1>
        <p class="mt-2 text-neutral-600">Organize your content with categories.</p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Category Form -->
        <div class="lg:col-span-1">
          <div class="bg-white rounded-lg shadow-sm p-6 border-2 border-chiffon-200">
            <h2 class="text-lg font-semibold text-neutral-850 mb-4">
              <%= if @editing_category, do: "Edit Category", else: "New Category" %>
            </h2>
            
            <.form for={@form} phx-submit={if @editing_category, do: "update", else: "create"} class="space-y-4">
              <div>
                <.input
                  field={@form[:name]}
                  type="text"
                  label="Name"
                  placeholder="Technology, Travel, etc."
                  required
                />
              </div>
              
              <div>
                <.input
                  field={@form[:slug]}
                  type="text"
                  label="Slug"
                  placeholder="auto-generated-from-name"
                />
                <p class="mt-1 text-sm text-neutral-500">Leave blank to auto-generate</p>
              </div>
              
              <div>
                <.input
                  field={@form[:description]}
                  type="textarea"
                  label="Description"
                  rows="3"
                  placeholder="Optional description for this category"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-neutral-700 mb-2">
                  Parent Category
                </label>
                <.input
                  field={@form[:parent_id]}
                  type="select"
                  options={[{"None", nil} | build_parent_options(@categories, @editing_category)]}
                />
              </div>
              
              <div>
                <.input
                  field={@form[:position]}
                  type="number"
                  label="Position"
                  value={@form[:position].value || 0}
                />
                <p class="mt-1 text-sm text-neutral-500">Lower numbers appear first</p>
              </div>
              
              <div class="flex gap-2">
                <.button 
                  type="submit"
                  class="flex-1 inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-sacramento-600 hover:bg-sacramento-700"
                >
                  <%= if @editing_category, do: "Update", else: "Create" %> Category
                </.button>
                
                <%= if @editing_category do %>
                  <.button
                    type="button"
                    phx-click="cancel-edit"
                    class="px-4 py-2 border border-neutral-300 text-sm font-medium rounded-md text-neutral-700 bg-white hover:bg-chiffon-100"
                  >
                    Cancel
                  </.button>
                <% end %>
              </div>
            </.form>
          </div>
        </div>

        <!-- Categories List -->
        <div class="lg:col-span-2">
          <div class="bg-white rounded-lg shadow-sm border-2 border-chiffon-200">
            <div class="px-6 py-4 border-b border-chiffon-200">
              <h2 class="text-lg font-semibold text-neutral-850">All Categories</h2>
            </div>
            
            <%= if @categories == [] do %>
              <div class="p-8 text-center text-neutral-500">
                <svg class="mx-auto h-12 w-12 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                </svg>
                <p class="mt-2">No categories yet. Create your first category!</p>
              </div>
            <% else %>
              <div class="divide-y divide-neutral-200">
                <%= for category <- @categories do %>
                  <div class="px-6 py-4 flex items-center justify-between hover:bg-chiffon-50 transition-colors">
                    <div class="flex-1">
                      <div class="flex items-center gap-2">
                        <h3 class="font-medium text-neutral-850">
                          <%= if category.parent do %>
                            <span class="text-neutral-400">└</span>
                          <% end %>
                          <%= category.name %>
                        </h3>
                        <span class="text-sm text-neutral-500">/<%= category.slug %></span>
                      </div>
                      <%= if category.description do %>
                        <p class="text-sm text-neutral-600 mt-1"><%= category.description %></p>
                      <% end %>
                      <%= if category.parent do %>
                        <p class="text-sm text-neutral-500 mt-1">
                          Parent: <%= category.parent.name %>
                        </p>
                      <% end %>
                    </div>
                    
                    <div class="flex items-center gap-2 ml-4">
                      <button
                        type="button"
                        phx-click="edit"
                        phx-value-id={category.id}
                        class="text-sacramento-600 hover:text-sacramento-700 font-medium text-sm"
                      >
                        Edit
                      </button>
                      <button
                        type="button"
                        phx-click="delete"
                        phx-value-id={category.id}
                        data-confirm="Are you sure you want to delete this category?"
                        class="text-red-600 hover:text-red-700 font-medium text-sm"
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("create", %{"category" => category_params}, socket) do
    case Admin.create_category(category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Category created successfully")
         |> assign(
           categories: Admin.list_categories(),
           form: to_form(Category.changeset(%Category{}, %{}))
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    category = Admin.get_category!(id)
    changeset = Category.changeset(category, %{})
    
    {:noreply,
     assign(socket,
       editing_category: category,
       form: to_form(changeset)
     )}
  end

  def handle_event("cancel-edit", _, socket) do
    {:noreply,
     assign(socket,
       editing_category: nil,
       form: to_form(Category.changeset(%Category{}, %{}))
     )}
  end

  def handle_event("update", %{"category" => category_params}, socket) do
    case Admin.update_category(socket.assigns.editing_category, category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Category updated successfully")
         |> assign(
           categories: Admin.list_categories(),
           editing_category: nil,
           form: to_form(Category.changeset(%Category{}, %{}))
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    category = Admin.get_category!(id)
    {:ok, _} = Admin.delete_category(category)
    
    {:noreply,
     socket
     |> put_flash(:info, "Category deleted successfully")
     |> assign(categories: Admin.list_categories())}
  end

  defp build_parent_options(categories, editing_category) do
    # Filter out the current category and its children to prevent circular references
    editing_id = if editing_category, do: editing_category.id, else: nil
    
    categories
    |> Enum.reject(fn cat -> 
      cat.id == editing_id || is_descendant_of?(cat, editing_id, categories)
    end)
    |> Enum.map(fn cat ->
      prefix = if cat.parent, do: "  ", else: ""
      {prefix <> cat.name, cat.id}
    end)
  end

  defp is_descendant_of?(category, nil, _categories), do: false
  defp is_descendant_of?(category, parent_id, categories) do
    cond do
      category.parent_id == parent_id -> true
      category.parent_id == nil -> false
      true ->
        parent = Enum.find(categories, &(&1.id == category.parent_id))
        parent && is_descendant_of?(parent, parent_id, categories)
    end
  end
end