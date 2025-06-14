defmodule BlogWeb.Components.MarkdownToolbar do
  use Phoenix.Component
  
  def markdown_toolbar(assigns) do
    ~H"""
    <div class="markdown-toolbar flex items-center gap-1 p-2 bg-neutral-50 border-b border-neutral-200 rounded-t-lg">
      <!-- Bold -->
      <button
        type="button"
        phx-click="format-text"
        phx-value-format="bold"
        title="Bold (Ctrl+B)"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4H7a1 1 0 00-1 1v14a1 1 0 001 1h5m0-16h2a3 3 0 013 3v0a3 3 0 01-3 3h-2m0 0h3a3 3 0 013 3v0a3 3 0 01-3 3h-3" />
        </svg>
      </button>
      
      <!-- Italic -->
      <button
        type="button"
        phx-click="format-text"
        phx-value-format="italic"
        title="Italic (Ctrl+I)"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 4h4m0 16h-4m4-16l-4 16" />
        </svg>
      </button>
      
      <!-- Strikethrough -->
      <button
        type="button"
        phx-click="format-text"
        phx-value-format="strikethrough"
        title="Strikethrough"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 12h8m-8 0H4m8 0V6m0 6v6" />
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 12h16" />
        </svg>
      </button>
      
      <div class="w-px h-6 bg-neutral-300 mx-1"></div>
      
      <!-- Heading -->
      <button
        type="button"
        phx-click="format-text"
        phx-value-format="heading"
        title="Heading"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h10m-5-8v16" />
        </svg>
      </button>
      
      <!-- Link -->
      <button
        type="button"
        phx-click="format-text"
        phx-value-format="link"
        title="Insert Link (Ctrl+K)"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" />
        </svg>
      </button>
      
      <!-- Image -->
      <button
        type="button"
        phx-click="toggle-media-picker"
        title="Insert Image"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
      </button>
      
      <div class="w-px h-6 bg-neutral-300 mx-1"></div>
      
      <!-- Code -->
      <button
        type="button"
        phx-click="format-text"
        phx-value-format="code"
        title="Inline Code"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
        </svg>
      </button>
      
      <!-- Code Block -->
      <button
        type="button"
        phx-click="format-text"
        phx-value-format="codeblock"
        title="Code Block"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
      </button>
      
      <div class="w-px h-6 bg-neutral-300 mx-1"></div>
      
      <!-- Unordered List -->
      <button
        type="button"
        phx-click="format-text"
        phx-value-format="unordered-list"
        title="Bullet List"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01" />
        </svg>
      </button>
      
      <!-- Ordered List -->
      <button
        type="button"
        phx-click="format-text"
        phx-value-format="ordered-list"
        title="Numbered List"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 20h14M7 10h14M7 6v4m0 0H3m4 0h4m-4 4v6m0-6H3m4 0h4" />
        </svg>
      </button>
      
      <!-- Blockquote -->
      <button
        type="button"
        phx-click="format-text"
        phx-value-format="quote"
        title="Blockquote"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
          <path d="M14 17h3l2-4V7h-6v6h3M6 17h3l2-4V7H5v6h3z" />
        </svg>
      </button>
      
      <div class="w-px h-6 bg-neutral-300 mx-1"></div>
      
      <!-- Table -->
      <button
        type="button"
        phx-click="format-text"
        phx-value-format="table"
        title="Insert Table"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M3 14h18m-9-4v8m-7 0h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
        </svg>
      </button>
      
      <!-- Horizontal Rule -->
      <button
        type="button"
        phx-click="format-text"
        phx-value-format="hr"
        title="Horizontal Rule"
        class="p-2 hover:bg-white rounded transition-colors"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14" />
        </svg>
      </button>
    </div>
    """
  end
end