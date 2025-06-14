defmodule Blog.Repo.Migrations.AddSeoFieldsToPostsAndDrafts do
  use Ecto.Migration

  def change do
    # Add SEO fields to posts table
    alter table(:posts) do
      add :meta_description, :text
      add :meta_keywords, :string
      add :og_title, :string
      add :og_description, :text
      add :og_image, :string
      add :twitter_card_type, :string, default: "summary_large_image"
      add :canonical_url, :string
      add :seo_data, :map, default: %{}
    end

    # Add SEO fields to drafts table
    alter table(:drafts) do
      add :meta_description, :text
      add :meta_keywords, :string
      add :og_title, :string
      add :og_description, :text
      add :og_image, :string
      add :twitter_card_type, :string, default: "summary_large_image"
      add :canonical_url, :string
      add :seo_data, :map, default: %{}
    end
  end
end
