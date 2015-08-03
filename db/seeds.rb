# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(name:  "Example",
             email: "example@railstutorial.org",
             password:              "123456",
             password_confirmation: "123456",
             admin:     true,
             activated: true,
             activated_at: Time.zone.now)

User.create!(name:  "D瓜哥",
             email: "lijun@diguage.com",
             password:              "123456",
             password_confirmation: "123456",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

98.times do |n|
  name  = Faker::Name.name
  if n < 10
    email = "example-#{n+2}@railstutorial.org"
  else
    email = "example-#{n+2}@diguage.com"
  end

  password = "123456"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end

users = User.order(:created_at).take(100) # TODO 如何进行按ID升序排列？为啥怎么试，都是最后几个呢？
50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content) }
end

# Following relationships
users = User.all
user = User.find(1) # TODO 为什么这里使用users.first确取不到第一个用户呢？
following = users[2..50]
followers = users[30..80]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
