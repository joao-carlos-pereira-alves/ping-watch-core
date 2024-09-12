# frozen_string_literal: true

class NotificationReceipt < ApplicationRecord
  belongs_to :notification

  enum notification_method: {
    email: 0,
    whatsapp: 1,
    sms: 2
  }

  def notification_method_label
    case notification_method
    when 'email'
      'Notificação via E-mail'
    when 'sms'
      'Notificação via SMS'
    when 'whatsapp'
      'Notificação via WhatsApp'
    else
      'Método de notificação desconhecido'
    end
  end
end
