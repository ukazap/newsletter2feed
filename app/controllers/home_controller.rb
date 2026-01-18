class HomeController < ApplicationController
  def index
    @feed = Feed.new
  end
end
