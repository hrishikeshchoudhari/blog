defmodule BlogWeb.ShowPost do
    use BlogWeb, :live_view

    require Logger
    use Timex

    alias Blog.Landing
    alias BlogWeb.Helpers.TocHelper
    import BlogWeb.LiveHelpers

    def mount(params, _session, socket) do
      %{"slug" => slug} = params
      post = Landing.get_post_by_slug(slug)
      
      # Determine the URL prefix based on post type
      url_prefix = case post.post_type do
        "project" -> "/project/"
        "reading" -> "/reading/"
        _ -> "/post/"
      end
      
      # Generate canonical URL
      canonical_url = post.canonical_url || BlogWeb.Endpoint.url() <> url_prefix <> post.slug
      
      # Generate table of contents and process body
      toc_html = TocHelper.generate_toc(post.raw_body || "")
      processed_body = TocHelper.add_heading_ids(post.body)
      
      # Find series info if post is part of a series
      {series_info, _post_position} = if post.series_id do
        series = post.series
        posts_in_series = series.posts |> Enum.sort_by(& &1.publishedDate)
        position = Enum.find_index(posts_in_series, &(&1.id == post.id))
        prev_post = if position && position > 0, do: Enum.at(posts_in_series, position - 1)
        next_post = if position && position < length(posts_in_series) - 1, do: Enum.at(posts_in_series, position + 1)
        
        {%{
          series: series,
          position: position && position + 1,
          total: length(posts_in_series),
          prev_post: prev_post,
          next_post: next_post
        }, position}
      else
        {nil, nil}
      end
      
      socket = 
        socket
        |> assign_sidebar_data()
        |> assign(
          post: post, 
          active_nav: :writing, 
          page_title: post.title,
          series_info: series_info,
          # SEO assigns
          meta_description: post.meta_description || String.slice(post.raw_body || "", 0, 160),
          meta_keywords: post.meta_keywords,
          og_type: "article",
          og_title: post.og_title || post.title,
          og_description: post.og_description || post.meta_description || String.slice(post.raw_body || "", 0, 160),
          og_image: post.og_image,
          twitter_card_type: post.twitter_card_type || "summary_large_image",
          canonical_url: canonical_url,
          skip_website_schema: true,
          # TOC assigns
          toc_html: toc_html,
          processed_body: processed_body
        )
        
      socket = if series_info, do: assign(socket, current_series: series_info.series), else: socket
      
      {:ok, socket}
    end

    def render(assigns) do
      ~H"""
      <div class="post">
        <script type="application/ld+json">
          <%= raw generate_schema_org(@post, @canonical_url) %>
        </script>
        
        <!-- Series Navigation Header -->
        <%= if @series_info do %>
          <div class="series-nav-header mb-8 p-6 bg-gradient-to-r from-orange-50 to-yellow-50 rounded-lg border border-orange-200">
            <div class="flex items-center justify-between mb-4">
              <div>
                <p class="text-sm text-gray-600 mb-1">This post is part of a series</p>
                <h3 class="text-xl font-bold font-snpro">
                  <.link navigate={"/series/" <> @series_info.series.slug} class="hover:text-orange-600 transition-colors">
                    <%= @series_info.series.title %>
                  </.link>
                </h3>
              </div>
              <div class="text-right">
                <span class="text-2xl font-bold text-orange-600">Part <%= @series_info.position %></span>
                <p class="text-sm text-gray-600">of <%= @series_info.total %></p>
              </div>
            </div>
            
            <!-- Progress bar -->
            <div class="w-full bg-gray-200 rounded-full h-2 mb-4">
              <div class="bg-orange-600 h-2 rounded-full" style={"width: #{(@series_info.position / @series_info.total) * 100}%"}></div>
            </div>
            
            <!-- Navigation buttons -->
            <div class="flex justify-between items-center">
              <%= if @series_info.prev_post do %>
                <.link 
                  navigate={get_post_url(@series_info.prev_post)} 
                  class="inline-flex items-center gap-2 text-sm text-orange-600 hover:text-orange-700 font-medium"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                  </svg>
                  Previous: <%= String.slice(@series_info.prev_post.title, 0, 30) %><%= if String.length(@series_info.prev_post.title) > 30, do: "..." %>
                </.link>
              <% else %>
                <div></div>
              <% end %>
              
              <%= if @series_info.next_post do %>
                <.link 
                  navigate={get_post_url(@series_info.next_post)} 
                  class="inline-flex items-center gap-2 text-sm text-orange-600 hover:text-orange-700 font-medium"
                >
                  Next: <%= String.slice(@series_info.next_post.title, 0, 30) %><%= if String.length(@series_info.next_post.title) > 30, do: "..." %>
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                  </svg>
                </.link>
              <% else %>
                <div></div>
              <% end %>
            </div>
          </div>
        <% end %>
        
        <h1 class="text-neutral-850 text-4xl font-snpro mt-20 mb-5 tracking-tighter">
          <%= @post.title %>
        </h1>
        
        <!-- Project-specific header -->
        <%= if @post.post_type == "project" do %>
          <div class="mb-6 p-4 bg-sacramento-50 rounded-lg border border-sacramento-200">
            <div class="flex flex-wrap gap-4">
              <%= if @post.demo_url do %>
                <a href={@post.demo_url} target="_blank" class="inline-flex items-center gap-2 px-4 py-2 bg-sacramento-600 text-white rounded-md hover:bg-sacramento-700 transition-colors">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                  </svg>
                  View Demo
                </a>
              <% end %>
              <%= if @post.github_url do %>
                <a href={@post.github_url} target="_blank" class="inline-flex items-center gap-2 px-4 py-2 bg-gray-800 text-white rounded-md hover:bg-gray-900 transition-colors">
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                  </svg>
                  View Source
                </a>
              <% end %>
            </div>
            <%= if @post.tech_stack && @post.tech_stack != [] do %>
              <div class="mt-4">
                <span class="text-sm font-medium text-sacramento-700">Tech Stack:</span>
                <div class="flex gap-2 flex-wrap mt-2">
                  <%= for tech <- @post.tech_stack do %>
                    <span class="text-sm bg-white px-3 py-1 rounded-full border border-sacramento-300">
                      <%= tech %>
                    </span>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
        
        <!-- Reading-specific header -->
        <%= if @post.post_type == "reading" do %>
          <div class="mb-6 p-4 bg-chiffon-50 rounded-lg border border-chiffon-200">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <%= if @post.author do %>
                <div>
                  <span class="text-sm font-medium text-gray-600">Author:</span>
                  <p class="text-lg font-semibold"><%= @post.author %></p>
                </div>
              <% end %>
              <%= if @post.rating do %>
                <div>
                  <span class="text-sm font-medium text-gray-600">My Rating:</span>
                  <div class="flex items-center gap-1 mt-1">
                    <%= for i <- 1..5 do %>
                      <svg class={"w-5 h-5 #{if i <= @post.rating, do: "text-yellow-500 fill-current", else: "text-gray-300 fill-current"}"} viewBox="0 0 20 20">
                        <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"/>
                      </svg>
                    <% end %>
                    <span class="ml-2 text-sm text-gray-600">(<%= @post.rating %>/5)</span>
                  </div>
                </div>
              <% end %>
              <%= if @post.date_read do %>
                <div>
                  <span class="text-sm font-medium text-gray-600">Date Read:</span>
                  <p class="text-lg"><%= Timex.format!(@post.date_read, "{Mfull} {YYYY}") %></p>
                </div>
              <% end %>
              <%= if @post.isbn do %>
                <div>
                  <span class="text-sm font-medium text-gray-600">ISBN:</span>
                  <p class="text-lg font-mono"><%= @post.isbn %></p>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>
        
        <div class="flex items-center gap-4 mb-5">
          <%= if @post.category do %>
            <.link navigate={"/category/" <> @post.category.slug} class="text-orange-600 hover:text-orange-700 font-medium">
              <%= @post.category.name %>
            </.link>
            <span class="text-gray-400">•</span>
          <% end %>
          <p class="text-neutral-500"><%= Timex.format!(@post.publishedDate, "{D} {Mfull} {YYYY}") %></p>
          <span class="text-gray-400">•</span>
          <p class="text-neutral-500"><%= estimate_reading_time(@post.body) %> min read</p>
        </div>
        
        <%= if @toc_html do %>
          <div class="toc-container mb-8 p-6 bg-chiffon-50 border-2 border-chiffon-200 rounded-lg">
            <%= raw @toc_html %>
          </div>
        <% end %>
        
        <div class="prose prose-xl prose-neutral max-w-none font-snpro post-body"><%= raw @processed_body %></div>
        
        <!-- Series Navigation Footer -->
        <%= if @series_info do %>
          <div class="series-nav-footer mt-12 p-6 bg-gradient-to-r from-orange-50 to-yellow-50 rounded-lg border border-orange-200">
            <h4 class="text-lg font-bold mb-4 font-snpro">Continue Reading <%= @series_info.series.title %></h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <%= if @series_info.prev_post do %>
                <.link 
                  navigate={get_post_url(@series_info.prev_post)} 
                  class="flex items-center gap-3 p-4 bg-white rounded-lg hover:shadow-md transition-shadow"
                >
                  <svg class="w-8 h-8 text-orange-600 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                  </svg>
                  <div class="text-left">
                    <p class="text-sm text-gray-600">Previous</p>
                    <p class="font-medium">Part <%= @series_info.position - 1 %>: <%= @series_info.prev_post.title %></p>
                  </div>
                </.link>
              <% else %>
                <div></div>
              <% end %>
              
              <%= if @series_info.next_post do %>
                <.link 
                  navigate={get_post_url(@series_info.next_post)} 
                  class="flex items-center gap-3 p-4 bg-white rounded-lg hover:shadow-md transition-shadow"
                >
                  <div class="text-left flex-1">
                    <p class="text-sm text-gray-600">Next</p>
                    <p class="font-medium">Part <%= @series_info.position + 1 %>: <%= @series_info.next_post.title %></p>
                  </div>
                  <svg class="w-8 h-8 text-orange-600 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                  </svg>
                </.link>
              <% else %>
                <div></div>
              <% end %>
            </div>
            
            <div class="mt-4 text-center">
              <.link 
                navigate={"/series/" <> @series_info.series.slug} 
                class="text-sm text-orange-600 hover:text-orange-700 font-medium"
              >
                View all <%= @series_info.total %> posts in this series →
              </.link>
            </div>
          </div>
        <% end %>
        
        <div id="post-bottom-border" class="mt-24 border-2 border-chiffon-200"></div>
      </div>
      
      <style>
        .toc-title {
          font-size: 1.125rem;
          font-weight: 600;
          margin-bottom: 0.75rem;
          color: #203040;
        }
        
        .toc-list {
          list-style: none;
          padding: 0;
          margin: 0;
        }
        
        .toc-list li {
          margin-bottom: 0.5rem;
        }
        
        .toc-list a {
          text-decoration: none;
          color: #607080;
          transition: color 0.2s;
        }
        
        .toc-list a:hover {
          color: #EB532D;
        }
        
        .toc-level-3 {
          padding-left: 1.5rem;
        }
        
        .toc-level-4 {
          padding-left: 3rem;
        }
        
        /* Smooth scrolling for TOC links */
        html {
          scroll-behavior: smooth;
        }
        
        /* Highlight target heading */
        :target {
          animation: highlight 2s;
        }
        
        @keyframes highlight {
          0% { background-color: #ffe5e5; }
          100% { background-color: transparent; }
        }
      </style>
      """
    end
    
    defp generate_schema_org(post, canonical_url) do
      schema = %{
        "@context" => "https://schema.org",
        "@type" => "BlogPosting",
        "headline" => post.title,
        "url" => canonical_url,
        "datePublished" => post.publishedDate |> DateTime.to_iso8601(),
        "dateModified" => (post.updated_at || post.inserted_at) |> DateTime.to_iso8601(),
        "author" => %{
          "@type" => "Person",
          "name" => "Rishi"
        },
        "publisher" => %{
          "@type" => "Person",
          "name" => "Rishi"
        },
        "mainEntityOfPage" => %{
          "@type" => "WebPage",
          "@id" => canonical_url
        }
      }
      
      # Add description if available
      schema = if post.meta_description do
        Map.put(schema, "description", post.meta_description)
      else
        schema
      end
      
      # Add image if available
      schema = if post.og_image do
        Map.put(schema, "image", post.og_image)
      else
        schema
      end
      
      # Add keywords if available
      schema = if post.meta_keywords do
        Map.put(schema, "keywords", post.meta_keywords)
      else
        schema
      end
      
      Jason.encode!(schema)
    end
    
    defp estimate_reading_time(content) do
      # Strip HTML tags and get plain text
      plain_text = content 
        |> String.replace(~r/<[^>]*>/, " ")
        |> String.replace(~r/\s+/, " ")
      
      # Rough estimate: 200 words per minute
      word_count = plain_text |> String.split() |> length()
      max(1, div(word_count, 200))
    end
    
    defp get_post_url(post) do
      case post.post_type do
        "project" -> "/project/" <> post.slug
        "reading" -> "/reading/" <> post.slug
        _ -> "/post/" <> post.slug
      end
    end

end
