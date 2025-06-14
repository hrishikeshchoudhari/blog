defmodule BlogWeb.DraftRevisionsLive do
  use BlogWeb, :admin_live_view
  alias Blog.Admin
  
  def mount(%{"draft_id" => draft_id}, _session, socket) do
    draft = Admin.get_draft!(draft_id)
    revisions = Admin.list_draft_revisions(draft_id)
    
    {:ok,
     socket
     |> assign(
       draft: draft,
       revisions: revisions,
       active_revision: nil,
       comparing: false,
       compare_revision: nil
     )}
  end
  
  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto">
      <div class="mb-6">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-neutral-850">Version History</h1>
            <p class="mt-2 text-neutral-600">
              <%= @draft.title %> • <%= length(@revisions) %> versions
            </p>
          </div>
          <.link 
            navigate={"/admin/draft/#{@draft.id}/edit"} 
            class="text-sacramento-600 hover:text-sacramento-700"
          >
            ← Back to editor
          </.link>
        </div>
      </div>
      
      <div class="grid grid-cols-3 gap-6">
        <!-- Revisions List -->
        <div class="col-span-1">
          <div class="bg-white rounded-lg shadow-sm border-2 border-chiffon-200 overflow-hidden">
            <div class="p-4 bg-chiffon-50 border-b border-chiffon-200">
              <h2 class="font-semibold text-neutral-850">Versions</h2>
            </div>
            <div class="divide-y divide-chiffon-200">
              <%= for revision <- @revisions do %>
                <button
                  phx-click="select-revision"
                  phx-value-id={revision.id}
                  class={"w-full text-left p-4 hover:bg-chiffon-50 transition-colors #{if @active_revision && @active_revision.id == revision.id, do: "bg-chiffon-100"}"}
                >
                  <div class="flex items-start justify-between">
                    <div class="flex-1">
                      <div class="text-sm font-medium text-neutral-850">
                        <%= if revision.auto_saved do %>
                          <span class="text-amber-600">Auto-saved</span>
                        <% else %>
                          <%= revision.revision_note || "Manual save" %>
                        <% end %>
                      </div>
                      <div class="text-xs text-neutral-600 mt-1">
                        <%= Calendar.strftime(revision.inserted_at, "%b %d, %Y at %I:%M %p") %>
                      </div>
                      <div class="text-xs text-neutral-500 mt-1">
                        by <%= revision.user.email %>
                      </div>
                    </div>
                    <%= if @active_revision && @active_revision.id == revision.id do %>
                      <svg class="w-4 h-4 text-sacramento-600 mt-1" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M6.293 9.293a1 1 0 011.414 0L10 11.586l2.293-2.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd" />
                      </svg>
                    <% end %>
                  </div>
                </button>
              <% end %>
            </div>
          </div>
        </div>
        
        <!-- Revision Details -->
        <div class="col-span-2">
          <%= if @active_revision do %>
            <div class="bg-white rounded-lg shadow-sm border-2 border-chiffon-200">
              <div class="p-4 bg-chiffon-50 border-b border-chiffon-200">
                <div class="flex items-center justify-between">
                  <h2 class="font-semibold text-neutral-850">
                    Version from <%= Calendar.strftime(@active_revision.inserted_at, "%b %d, %Y at %I:%M %p") %>
                  </h2>
                  <div class="flex items-center gap-2">
                    <button
                      phx-click="toggle-compare"
                      class={"px-3 py-1 text-sm font-medium rounded-md #{if @comparing, do: "bg-sacramento-600 text-white", else: "bg-white border border-neutral-300 text-neutral-700 hover:bg-chiffon-100"}"}
                    >
                      <%= if @comparing do %>
                        Hide Comparison
                      <% else %>
                        Compare with Current
                      <% end %>
                    </button>
                    <button
                      phx-click="restore-revision"
                      phx-value-id={@active_revision.id}
                      onclick="return confirm('Are you sure you want to restore this version? The current draft will be saved as a new revision.');"
                      class="px-3 py-1 text-sm font-medium rounded-md bg-sacramento-600 text-white hover:bg-sacramento-700"
                    >
                      Restore This Version
                    </button>
                  </div>
                </div>
              </div>
              
              <div class="p-6">
                <!-- Title -->
                <div class="mb-6">
                  <h3 class="text-sm font-medium text-neutral-700 mb-2">Title</h3>
                  <div class="p-3 bg-neutral-50 rounded-md">
                    <%= if @comparing && @active_revision.title != @draft.title do %>
                      <div class="text-red-600 line-through"><%= @draft.title %></div>
                      <div class="text-green-600"><%= @active_revision.title %></div>
                    <% else %>
                      <%= @active_revision.title %>
                    <% end %>
                  </div>
                </div>
                
                <!-- Slug -->
                <div class="mb-6">
                  <h3 class="text-sm font-medium text-neutral-700 mb-2">Slug</h3>
                  <div class="p-3 bg-neutral-50 rounded-md font-mono text-sm">
                    <%= if @comparing && @active_revision.slug != @draft.slug do %>
                      <div class="text-red-600 line-through"><%= @draft.slug %></div>
                      <div class="text-green-600"><%= @active_revision.slug %></div>
                    <% else %>
                      <%= @active_revision.slug %>
                    <% end %>
                  </div>
                </div>
                
                <!-- Content -->
                <div class="mb-6">
                  <h3 class="text-sm font-medium text-neutral-700 mb-2">Content</h3>
                  <div class="border border-neutral-200 rounded-lg overflow-hidden">
                    <pre class="p-4 bg-neutral-50 overflow-x-auto text-sm"><%= @active_revision.raw_body || @active_revision.body %></pre>
                  </div>
                </div>
                
                <!-- Metadata -->
                <details class="border-t border-neutral-200 pt-4">
                  <summary class="cursor-pointer text-sm font-medium text-neutral-700 mb-2">
                    SEO & Metadata
                  </summary>
                  <div class="mt-4 space-y-3 text-sm">
                    <%= if @active_revision.meta_description do %>
                      <div>
                        <span class="font-medium text-neutral-600">Meta Description:</span>
                        <span class="text-neutral-800"><%= @active_revision.meta_description %></span>
                      </div>
                    <% end %>
                    <%= if @active_revision.meta_keywords do %>
                      <div>
                        <span class="font-medium text-neutral-600">Keywords:</span>
                        <span class="text-neutral-800"><%= @active_revision.meta_keywords %></span>
                      </div>
                    <% end %>
                    <%= if @active_revision.og_title do %>
                      <div>
                        <span class="font-medium text-neutral-600">OG Title:</span>
                        <span class="text-neutral-800"><%= @active_revision.og_title %></span>
                      </div>
                    <% end %>
                    <%= if @active_revision.og_image do %>
                      <div>
                        <span class="font-medium text-neutral-600">OG Image:</span>
                        <span class="text-neutral-800"><%= @active_revision.og_image %></span>
                      </div>
                    <% end %>
                  </div>
                </details>
              </div>
            </div>
          <% else %>
            <div class="bg-white rounded-lg shadow-sm border-2 border-chiffon-200 p-12 text-center">
              <svg class="w-12 h-12 text-neutral-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              <p class="text-neutral-600">Select a version from the list to view details</p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
  
  def handle_event("select-revision", %{"id" => id}, socket) do
    revision = Enum.find(socket.assigns.revisions, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, active_revision: revision, comparing: false)}
  end
  
  def handle_event("toggle-compare", _, socket) do
    {:noreply, assign(socket, comparing: !socket.assigns.comparing)}
  end
  
  def handle_event("restore-revision", %{"id" => id}, socket) do
    case Admin.restore_draft_from_revision(
      socket.assigns.draft.id,
      String.to_integer(id),
      socket.assigns.current_users.id
    ) do
      {:ok, _updated_draft} ->
        {:noreply,
         socket
         |> put_flash(:info, "Version restored successfully")
         |> push_navigate(to: "/admin/draft/#{socket.assigns.draft.id}/edit")}
      
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to restore version")}
    end
  end
end