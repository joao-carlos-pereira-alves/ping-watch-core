# frozen_string_literal: true

# lib/notification_service/sms_notification.rb
module NotificationService
  class SmsNotification < NotificationStrategy
    def send(notification, recipient)
      # Lógica para envio de SMS
      puts "Enviando SMS para #{recipient}: #{notification}"
      # Aqui você pode implementar o envio de SMS usando uma API externa
      'Comprovante de envio por SMS'
    end
  end
end
