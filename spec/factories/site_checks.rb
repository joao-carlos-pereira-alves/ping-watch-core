# spec/factories/site_checks.rb
FactoryBot.define do
  factory :site_check do
    site
    check_status { %w[unknown online offline timeout maintenance forbidden].sample } # Status aleatório do enum
    response_time_ms { 100 }
  end
end
