class Feed < ApplicationRecord
  include AtomFeedBuildable
  include PublicIdGeneratable

  has_many :feed_entries, dependent: :destroy
  has_many :feed_hits, dependent: :destroy

  validates :title, presence: true

  RATE_LIMIT_VIEWS = 10
  RATE_LIMIT_PERIOD = 1.hour
  MAX_CONTENT_SIZE = 1024.kilobytes

  def email_address
    "#{public_id}@#{Rails.configuration.app_hostname}"
  end

  def feed_url
    Rails.application.routes.url_helpers.feed_url(public_id, host: Rails.configuration.app_hostname)
  end

  def atom_url
    Rails.application.routes.url_helpers.feed_url(public_id, format: :xml, host: Rails.configuration.app_hostname)
  end

  def rate_limited?
    feed_hits.where("created_at > ?", RATE_LIMIT_PERIOD.ago).count >= RATE_LIMIT_VIEWS
  end

  def record_hit!
    feed_hits.create!
  end

  def prune_entries!
    while total_content_size > MAX_CONTENT_SIZE && feed_entries.count > 1
      oldest_entry = feed_entries.order(:created_at).first
      oldest_entry.destroy
    end
  end

  def self.find_by_email(email)
    local_part = email&.split("@")&.first&.downcase
    find_by(public_id: local_part) if local_part.present?
  end

  private
    def total_content_size
      feed_entries.sum("LENGTH(COALESCE(content, ''))")
    end
end
