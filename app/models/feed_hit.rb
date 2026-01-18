class FeedHit < ApplicationRecord
  belongs_to :feed

  def self.cleanup_old!
    where("created_at < ?", 1.hour.ago).delete_all
  end
end
