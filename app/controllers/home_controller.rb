class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @tweets = Tweet.all.order(created_at: :desc).page(params[:page]).per(50)
    @tweet = Tweet.new
  end
end
