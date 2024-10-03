# spec/factories/notifications.rb
FactoryBot.define do
  factory :notification do
    user
    notification_method { :email }
    threshold_value { Notification::DEFAULT_THRESHOLD_VALUE }
    frequency { :hourly }

    # Adicione `sequence` se precisar garantir valores únicos
    sequence(:notification_method) { |n| "email#{n}" }
  end
end
