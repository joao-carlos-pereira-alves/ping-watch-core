# spec/factories/sites.rb
FactoryBot.define do
  factory :site do
    user
    url { 'http://example.com' }
  end
end
