class FeedEntriesController < ApplicationController
  before_action :set_feed
  before_action :set_entry

  def show
  end

  private

  def set_feed
    @feed = Feed.find_by!(public_id: params[:feed_public_id])
  end

  def set_entry
    @entry = @feed.feed_entries.find_by!(public_id: params[:public_id])
  end
end
