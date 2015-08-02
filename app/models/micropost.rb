class Micropost < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true,
                      length: { maximum: 140 }
end


# 模型中代码放置顺序参考：[Rails Style Guide](https://github.com/JuanitoFatas/rails-style-guide/blob/master/README-zhCN.md#-5)
# 1. 默认的scope放在最前面(如果有), default_scope
# 2. 接下来是常量
# 3. 然后放一些attr相关的宏, attr_accessor
# 4. 仅接着是关联的宏, belongs_to, has_many
# 5. 以及宏的验证, validates
# 6. 接着是回调, before_save
