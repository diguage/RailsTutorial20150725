class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper

  private
    # 确保用户已经登录
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in" # TODO 这里为什么不用flash.now呢？
        redirect_to login_url
      end
    end
end
