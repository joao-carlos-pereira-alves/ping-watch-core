class Notification < ApplicationRecord
  belongs_to :user

  enum alert_type: {
    response_time: 0,
    status_code: 1,
    uptime: 2
  }

  enum frequency: {
    hourly: 0,
    minutes: 1,
    daily: 2,
    immediate: 3
  }

  enum notification_method: {
    email: 0,
    whatsapp: 1,
    sms: 2
  }

  validates :notification_method,
            uniqueness: { scope: %i[user_id], message: 'Método de notificação já cadastrado' }
end
