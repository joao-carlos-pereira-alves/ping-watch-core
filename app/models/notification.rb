# frozen_string_literal: true

require_relative '../../lib/notification_service/notification_sender'
require_relative '../../lib/notification_service/notification_strategy'
require_relative '../../lib/notification_service/email_notification'

class Notification < ApplicationRecord
  has_many :notification_receipts, dependent: :destroy
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

  before_create :set_uuid

  validates :notification_method,
            uniqueness: { scope: %i[user_id], message: 'Método de notificação já cadastrado' }

  def perform(site)
    notification_strategy = map_notification_method_strategy
    sender = NotificationService::NotificationSender.new(notification_strategy)
    sender.execute(self, site)
  end

  def increment_notification_receipts_count
    self.notification_receipts_count = notification_receipts_count + 1
  end

  def threshold_value_label
    case alert_type
    when 'response_time'
      "#{threshold_value} ms"
    when 'status_code'
      "Status: #{threshold_value}"
    when 'uptime'
      "#{threshold_value}%"
    end
  end

  def alert_type_label
    case alert_type
    when 'response_time'
      'Tempo de Resposta'
    when 'status_code'
      'Código de Status'
    when 'uptime'
      ''
    end
  end

  def frequency_label
    case frequency
    when 'hourly'
      'A cada Hora'
    when 'minutes'
      'A cada Minuto'
    when 'daily'
      'Diário'
    when 'immediate'
      'Imediato'
    end
  end

  def notification_method_label
    if notification_method.eql?('email')
      {
        title: 'Notificação por Email',
        subtitle: 'Configure alertas de monitoramento via email.'
      }
    elsif notification_method.eql?('sms')
      {
        title: 'Notificação por SMS',
        subtitle: 'Receba alertas de monitoramento via SMS.'
      }
    elsif notification_method.eql?('whatsapp')
      {
        title: 'Notificação por Whatsapp',
        subtitle: 'Receba alertas de monitoramento via Whastapp.'
      }
    end
  end

  private

  def set_uuid
    self.uuid = SecureRandom.uuid
  end

  def call_email_strategy
  end

  def map_notification_method_strategy
    case notification_method
    when 'email'
      NotificationService::EmailNotification.new
    when 'sms'
      NotificationService::SmsNotification.new
    else
      puts "\n Estratégia de notificação não permitida."
      nil
    end
  end
end
