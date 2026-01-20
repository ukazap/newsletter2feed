class FeedEntriesController < ApplicationController
  def show
    @entry = FeedEntry.find_by!(public_id: params[:public_id])
    @feed = @entry.feed
  end
end
