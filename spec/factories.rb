# spec/factories.rb

FactoryBot.define do
  factory :plan do
    name { :free }
  end

  factory(:user) do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    association :plan, factory: :plan
  end
  
  factory(:site) do
    url { 'http://example.com' }
    association :user
  end
end
