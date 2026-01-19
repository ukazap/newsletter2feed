class FeedEntry < ApplicationRecord
  include PublicIdGeneratable

  belongs_to :feed
  has_many_attached :enclosures

  validates :title, presence: true

  def entry_url
    Rails.application.routes.url_helpers.feed_entry_url(
      feed.public_id,
      public_id,
      host: Rails.configuration.app_hostname
    )
  end

  def content_with_footer
    footer = <<~HTML
      <footer>
        <p>
          <a href="#{entry_url}">View in browser</a>
          &nbsp;·&nbsp;
          <a href="#{feed.feed_url}">Feed settings</a>
        </p>
      </footer>
    HTML

    "#{content}#{footer}"
  end
end
