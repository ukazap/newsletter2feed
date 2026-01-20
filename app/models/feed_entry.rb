class FeedEntry < ApplicationRecord
  include PublicIdGeneratable

  belongs_to :feed
  has_many_attached :enclosures

  validates :title, presence: true

  def entry_url
    Rails.application.routes.url_helpers.feed_entry_url(public_id, host: Rails.configuration.app_hostname)
  end

  def content_with_footer
    footer = <<~HTML
      <footer>
        <p>Newsletter2Feed: <a href="#{feed.feed_url}">Feed settings</a></p>
      </footer>
    HTML

    "#{content}#{footer}"
  end
end
