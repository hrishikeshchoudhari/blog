defmodule BlogWeb.Router do
  use BlogWeb, :router

  import BlogWeb.UsersAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BlogWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_users
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlogWeb do
  #   pipe_through :api
  # ensure_authenticated

  # Enable LiveDashboard for all environments with authentication
  import Phoenix.LiveDashboard.Router

  scope "/admin" do
    pipe_through [:browser, :require_authenticated_users]
    
    live_dashboard "/dashboard", 
      metrics: BlogWeb.Telemetry,
      ecto_repos: [Blog.Repo]
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:blog, :dev_routes) do
    scope "/dev" do
      pipe_through :browser
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", BlogWeb do
    pipe_through [:browser, :redirect_if_users_is_authenticated]

    live_session :redirect_if_users_is_authenticated, layout: {BlogWeb.Layouts, :auth},
      on_mount: [{BlogWeb.UsersAuth, :redirect_if_users_is_authenticated}] do
      live "/users/register", UsersRegistrationLive, :new
      live "/users/log_in", UsersLoginLive, :new
      live "/users/reset_password", UsersForgotPasswordLive, :new
      live "/users/reset_password/:token", UsersResetPasswordLive, :edit
    end

    post "/users/log_in", UsersSessionController, :create
  end

  scope "/", BlogWeb do
    pipe_through [:browser, :require_authenticated_users]

    live_session :require_authenticated_users, layout: {BlogWeb.Layouts, :admin},
      on_mount: [{BlogWeb.UsersAuth, :ensure_authenticated}] do

      live "/admin", AdminHome
      live "/admin/posts", AdminPosts
      live "/admin/pages", AdminPages
      live "/admin/draft", WriteDraft
      live "/admin/post/:id/edit", EditContent, :edit_post, as: :edit_post
      live "/admin/draft/:id/edit", EditContent, :edit_draft, as: :edit_draft
      live "/admin/draft/:draft_id/revisions", DraftRevisionsLive
      live "/admin/media", MediaLibraryLive
      live "/upload", UploadLive
      live "/admin/tags", TagsActions
      live "/admin/categories", AdminCategories
      live "/admin/series", AdminSeries

      live "/users/settings", UsersSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UsersSettingsLive, :confirm_email
    end
  end

  scope "/", BlogWeb do
    pipe_through [:browser]

    delete "/users/log_out", UsersSessionController, :delete

    live_session :current_users, layout: {BlogWeb.Layouts, :auth},
      on_mount: [{BlogWeb.UsersAuth, :mount_current_users}] do
      live "/users/confirm/:token", UsersConfirmationLive, :edit
      live "/users/confirm", UsersConfirmationInstructionsLive, :new
    end
  end

  scope "/", BlogWeb do
    pipe_through :browser

    live "/", Home
    live "/about", About
    # live "/post/:slug", ShowPost
    live "/tag/:tagslug", AllPostsForTag
    live "/post/:slug", ShowPost
    live "/projects", Projects
    live "/readings", Readings
    live "/changelog", Changelog
    live "/series", SeriesIndex
    live "/series/:slug", SeriesShow
    live "/category/:slug", CategoryShow
    
    # SEO routes
    get "/sitemap.xml", SitemapController, :index
    
    # Feed routes
    get "/feed.xml", FeedController, :index
    get "/rss.xml", FeedController, :rss
    get "/feeds.opml", FeedController, :opml
    get "/category/:slug/feed.xml", FeedController, :category
    get "/series/:slug/feed.xml", FeedController, :series
    get "/tag/:slug/feed.xml", FeedController, :tag

  end
end
