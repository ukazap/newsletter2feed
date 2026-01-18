require "test_helper"

class FeedEntryTest < ActiveSupport::TestCase
  test "generates public_id on create" do
    entry = feeds(:tech_news).feed_entries.create!(title: "Test Entry")

    assert_match(/\A[a-z0-9]{20}\z/, entry.public_id)
  end

  test "content_with_footer appends footer with links" do
    entry = feed_entries(:welcome_email)

    result = entry.content_with_footer

    assert_includes result, entry.content
    assert_includes result, "View in browser"
    assert_includes result, "Feed settings"
    assert_includes result, entry.entry_url
    assert_includes result, entry.feed.feed_url
  end

  test "content_with_footer handles nil content" do
    entry = feeds(:tech_news).feed_entries.create!(title: "No Content", content: nil)

    result = entry.content_with_footer

    assert_includes result, "<footer>"
  end
end
