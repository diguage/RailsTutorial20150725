module SessionsHelper

  # 登入指定的用户
  def log_in(user)
    session[:user_id] = user.id
  end

  # 返回当前登录的用户（如果有的话）
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) # TODO 为啥不能使用User.find(session[:user_id])
  end

  # 如果用户登录，则返回true；否则返回false。
  def logged_in?
    !current_user.nil?
  end
end
