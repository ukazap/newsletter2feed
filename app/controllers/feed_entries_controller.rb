class FeedEntriesController < ApplicationController
  def show
    @feed = Feed.find_by!(public_id: params[:feed_public_id])
    @entry = @feed.feed_entries.find_by!(public_id: params[:public_id])
  end
end
