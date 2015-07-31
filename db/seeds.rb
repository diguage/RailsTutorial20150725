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
             admin: true)

User.create!(name:  "D瓜哥",
             email: "lijun@diguage.com",
             password:              "123456",
             password_confirmation: "123456",
             admin: true)

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