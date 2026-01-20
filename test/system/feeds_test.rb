require "application_system_test_case"

class FeedsTest < ApplicationSystemTestCase
  test "visiting the home page" do
    visit root_path

    assert_text "Get a unique email address that turns newsletters into Atom feeds"
    assert_text "How it works"
    assert_button "Create Feed"
  end

  test "creating a feed" do
    visit root_path

    fill_in "Feed title", with: "My Newsletter Feed"
    click_button "Create Feed"

    assert_text "My Newsletter Feed"
    assert_text "Email address (subscribe to newsletters with this)"
    assert_text "Atom feed URL (add this to your feed reader)"
    assert_selector "code", minimum: 2
    assert_text "No entries yet"
  end

  test "creating a feed without title shows error" do
    visit root_path

    click_button "Create Feed"

    assert_current_path root_path
  end

  test "viewing a feed with entries" do
    feed = feeds(:tech_news)

    visit feed_path(feed.public_id)

    assert_text feed.title
    assert_text feed.email_address
    assert_text "Entries (2)"
    assert_link "Welcome to Tech News"
    assert_link "This Week in Tech"
  end

  test "updating feed title" do
    feed = feeds(:tech_news)

    visit feed_path(feed.public_id)

    fill_in "Feed title", with: "Updated Newsletter"
    click_button "Update Feed"

    assert_text "Updated Newsletter"
    assert_selector "h1", text: "Updated Newsletter"
  end

  test "updating feed icon" do
    feed = feeds(:empty_feed)

    visit feed_path(feed.public_id)

    fill_in "Icon URL (optional)", with: "https://example.com/new-icon.png"
    click_button "Update Feed"

    assert_field "Icon URL (optional)", with: "https://example.com/new-icon.png"
  end

  test "viewing a feed entry" do
    entry = feed_entries(:welcome_email)

    visit feed_entry_path(entry.public_id)

    assert_text entry.title
    assert_text "From: #{entry.author}"
    within_frame("feed-content") do
      assert_text "Welcome!"
      assert_text "Thanks for subscribing to our newsletter."
    end
  end

  test "navigating from feed to entry" do
    feed = feeds(:tech_news)
    entry = feed_entries(:welcome_email)

    visit feed_path(feed.public_id)
    click_link "Welcome to Tech News"

    assert_current_path feed_entry_path(entry.public_id)

    within_frame("feed-content") do
      assert_text "Welcome!"
      assert_text "Thanks for subscribing to our newsletter."
    end
  end

  test "deleting a feed" do
    feed = feeds(:empty_feed)

    visit feed_path(feed.public_id)

    accept_confirm "Are you sure you want to delete this feed?" do
      click_button "Delete Feed"
    end

    assert_current_path root_path
    assert_no_text feed.title
  end
end
