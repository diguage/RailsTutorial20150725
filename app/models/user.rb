class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_accessor :remember_token, :activation_token

  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :password, length: {minimum: 6}, allow_blank: true

  before_create :create_activation_digest     # TODO 有哪些回调函数？
  before_save   :downcase_email

  has_secure_password

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # 返回一个随机令牌
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 为了持久会话，在数据库中记住用户
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_digest))
  end

  # 如果指定的令牌和摘要匹配，返回true
  def authenticated?(remember_token)
    return false if remember_digest.nil? # TODO 这个问题没有复现。8.4.4第二个问题。
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # 忘记用户
  def forget
    update_attribute(:remember_digest, nil)
  end

  private
    # 把电子邮件地址转换成小写
    def downcase_email
      self.email = email.downcase # TODO 为啥后面的self可以省略，而前面的却不能省略？
    end

    # 创建令牌和摘要
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token) # TODO 为什么这里上面那句activation_token前要加self，而这句则不用加self？
    end
end


# 模型中代码放置顺序参考：[Rails Style Guide](https://github.com/JuanitoFatas/rails-style-guide/blob/master/README-zhCN.md#-5)
# 1. 默认的scope放在最前面(如果有)
# 2. 接下来是常量
# 3. 然后放一些attr相关的宏
# 4. 仅接着是关联的宏
# 5. 以及宏的验证
# 6. 接着是回调