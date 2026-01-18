require "test_helper"

class FeedHitTest < ActiveSupport::TestCase
  test "cleanup_old! deletes hits older than one hour" do
    feed = feeds(:tech_news)
    old_hit = feed.feed_hits.create!(created_at: 2.hours.ago)
    recent_hit = feed.feed_hits.create!(created_at: 30.minutes.ago)

    FeedHit.cleanup_old!

    assert_not FeedHit.exists?(old_hit.id)
    assert FeedHit.exists?(recent_hit.id)
  end
end
