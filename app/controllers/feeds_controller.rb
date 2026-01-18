class FeedsController < ApplicationController
  before_action :set_feed, only: [ :show, :update, :destroy ]

  def create
    @feed = Feed.new(feed_params)

    if @feed.save
      redirect_to feed_path(@feed.public_id), notice: "Feed created successfully."
    else
      render "home/index", status: :unprocessable_entity
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml do
        if @feed.rate_limited?
          head :too_many_requests
        else
          @feed.record_hit!
          response.headers["X-Robots-Tag"] = "none"
          render xml: AtomFeedBuilder.new(@feed).to_xml
        end
      end
    end
  end

  def update
    if @feed.update(feed_params)
      redirect_to feed_path(@feed.public_id), notice: "Feed updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @feed.destroy
    redirect_to root_path, notice: "Feed deleted successfully."
  end

  private

  def set_feed
    @feed = Feed.find_by!(public_id: params[:public_id])
  end

  def feed_params
    params.require(:feed).permit(:title, :icon, :email_icon)
  end
end
