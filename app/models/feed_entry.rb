class FeedEntry < ApplicationRecord
  belongs_to :feed
  has_many_attached :enclosures

  validates :public_id, presence: true, uniqueness: true, length: { is: 20 }
  validates :title, presence: true

  before_validation :generate_public_id, on: :create

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
          <a href="#{entry_url}">Entry settings</a>
          &nbsp;·&nbsp;
          <a href="#{feed.feed_url}">Feed settings</a>
        </p>
      </footer>
    HTML

    "#{content}#{footer}"
  end

  private

  def generate_public_id
    self.public_id ||= SecureRandom.alphanumeric(20).downcase
  end
end
