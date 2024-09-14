# spec/factories/notifications.rb
FactoryBot.define do
  factory :notification do
    user
    alert_type { :status_code }  # Valor padrão para alert_type
    frequency { :daily }         # Valor padrão para frequency
    notification_method { :email } # Valor padrão para notification_method
    threshold_value { 200 } # Valor padrão para threshold_value

    # Se o modelo tiver associações, certifique-se de adicionar
    # todas as relações necessárias, como o user
  end
end
