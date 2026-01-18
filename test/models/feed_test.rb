require "test_helper"

class FeedTest < ActiveSupport::TestCase
  test "generates public_id on create" do
    feed = Feed.create!(title: "Test Feed")

    assert_match(/\A[a-z0-9]{20}\z/, feed.public_id)
  end

  test "does not overwrite existing public_id" do
    feed = Feed.new(title: "Test", public_id: "customid1234567890xy")
    feed.save!

    assert_equal "customid1234567890xy", feed.public_id
  end

  test "find_by_email returns nil for blank email" do
    assert_nil Feed.find_by_email(nil)
    assert_nil Feed.find_by_email("")
  end

  test "find_by_email returns nil for invalid format" do
    assert_nil Feed.find_by_email("short@example.com")
    assert_nil Feed.find_by_email("toolongtobevalid12345@example.com")
    assert_nil Feed.find_by_email("has_special_chars!!@example.com")
    assert_nil Feed.find_by_email("not-an-email")
  end

  test "find_by_email finds feed by public_id" do
    feed = feeds(:tech_news)

    found = Feed.find_by_email("#{feed.public_id}@example.com")

    assert_equal feed, found
  end

  test "find_by_email is case insensitive" do
    feed = feeds(:tech_news)

    found = Feed.find_by_email("#{feed.public_id.upcase}@EXAMPLE.COM")

    assert_equal feed, found
  end

  test "rate_limited? returns false when under limit" do
    feed = feeds(:empty_feed)
    5.times { feed.record_hit! }

    assert_not feed.rate_limited?
  end

  test "rate_limited? returns true when at limit" do
    feed = feeds(:empty_feed)
    Feed::RATE_LIMIT_VIEWS.times { feed.record_hit! }

    assert feed.rate_limited?
  end

  test "rate_limited? ignores old hits" do
    feed = feeds(:empty_feed)
    Feed::RATE_LIMIT_VIEWS.times do
      feed.feed_hits.create!(created_at: 2.hours.ago)
    end

    assert_not feed.rate_limited?
  end

  test "prune_entries! removes oldest entries when over size limit" do
    feed = feeds(:empty_feed)
    large_content = "x" * 600.kilobytes

    old_entry = feed.feed_entries.create!(title: "Old", content: large_content, created_at: 1.day.ago)
    new_entry = feed.feed_entries.create!(title: "New", content: large_content, created_at: Time.current)

    feed.prune_entries!

    assert_not FeedEntry.exists?(old_entry.id)
    assert FeedEntry.exists?(new_entry.id)
  end

  test "prune_entries! keeps at least one entry" do
    feed = feeds(:empty_feed)
    huge_content = "x" * 2.megabytes

    entry = feed.feed_entries.create!(title: "Only One", content: huge_content)

    feed.prune_entries!

    assert FeedEntry.exists?(entry.id)
  end

  test "prune_entries! does nothing when under limit" do
    feed = feeds(:tech_news)
    initial_count = feed.feed_entries.count

    feed.prune_entries!

    assert_equal initial_count, feed.feed_entries.count
  end
end
