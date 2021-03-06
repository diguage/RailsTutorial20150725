class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instruction'
      redirect_to root_url
    else
      flash[:danger] = 'Email not found'
      render 'new'
    end
  end

  def edit
    @user = User.find_by(email: params[:email])
    if @user
    else
      flash[:danger] = "Invalid reset link"
      redirect_to root_url
    end
  end

  def update
    if password_blank?
      flash.now[:danger] = "Password can't blank."
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "Password has been reset"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private
    def user_params
      params.require(:user).permit(:password, :password_confirmation)

    end

  # 如果密码为空,返回 true
    def password_blank?
      params[:user][:password].blank?
    end

    # 事前过滤器

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 确保是有效用户
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # 检查重设令牌是否过期
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = 'Password reset has expired.'
        redirect_to password_reset_url
      end
    end
end
