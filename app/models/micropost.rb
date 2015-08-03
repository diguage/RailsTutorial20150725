class Micropost < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true,
                      length: { maximum: 140 }
  validate  :picture_size  # TODO 注意学习这种自定义校验的方式

  mount_uploader :picture, PictureUploader

  private
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end


# 模型中代码放置顺序参考：[Rails Style Guide](https://github.com/JuanitoFatas/rails-style-guide/blob/master/README-zhCN.md#-5)
# 1. 默认的scope放在最前面(如果有), default_scope
# 2. 接下来是常量
# 3. 然后放一些attr相关的宏, attr_accessor
# 4. 仅接着是关联的宏, belongs_to, has_many
# 5. 以及宏的验证, validates
# 6. 接着是回调, before_save
