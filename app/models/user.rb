class User < ActiveRecord::Base
  default_scope -> { order(created_at: :desc) }  # TODO 如何默认的scope不生效？

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_accessor :remember_token, :activation_token, :reset_token

  has_many :microposts, dependent: :destroy  # TODO 这些都是没有条件的？如何加一些条件？如何只选取没有被删除的？
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed # TODO source是啥意思？
  has_many :followers, through: :passive_relationships, source: :follower # TODO 感觉好繁琐，多对多关联，有这么繁琐吗？


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
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil? # TODO 这个问题没有复现。8.4.4第二个问题。
    BCrypt::Password.new(digest).is_password?(token)
  end

  # 忘记用户
  def forget
    update_attribute(:remember_digest, nil)
  end

  # 激活账号
  def activate
    update_attributes(activated:    true,
                      activated_at: Time.zone.now)
  end

  # 发送激活邮件
  def send_activation_email
    UserMailer.account_activation(self).deliver_now # TODO 如何使用后台任务来完成？resque, sidekiq, delayed_job
  end

  # 设置密码重设相关的属性
  def create_reset_digest
    self.reset_token = User.new_token
    update_attributes(reset_digest:  User.digest(reset_token),
                      reset_sent_at: Time.zone.now) # TODO 书中使用update_columns，这两个方法有什么区别？
  end

  # 送密码重设邮件
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # 如果密码重置超时失效了，则返回true
  def password_reset_expired?
    reset_sent_at < 2.hour.ago
  end

  # 实现动态流原型
  # 完整的实现参见第12章
  def feed
    # 第一种方式
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id) # TODO 如何用户特别多，超过限制怎么办？比如Oracle数据中，IN中的ID只能在四千内的。
    # 第二种方式 TODO 这种方式并没有很好的解决上面的问题，只是把上面查一次数据库，变成了查两次数据库。思考有没有更好的方式？
    following_ids = "SELECT followed_id
                     FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
  end

  # 关注另外一个用户
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # 取消关注另外一个用户
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 如果当前用户关注了指定的用户，返回true
  def following?(other_user)
    following.include?(other_user)
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
# 1. 默认的scope放在最前面(如果有), default_scope
# 2. 接下来是常量
# 3. 然后放一些attr相关的宏, attr_accessor
# 4. 仅接着是关联的宏, belongs_to, has_many
# 5. 以及宏的验证, validates
# 6. 接着是回调, before_save