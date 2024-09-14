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
    every_5_minutes: 0,
    every_10_minutes: 1,
    every_30_minutes: 2,
    hourly: 3,
    immediate: 4,
    daily: 5
  }

  enum notification_method: {
    email: 0,
    whatsapp: 1,
    sms: 2
  }

  before_create :set_uuid

  validates :notification_method,
            uniqueness: { scope: %i[user_id], message: 'Método de notificação já cadastrado' }

  validate :threshold_value_validation

  DEFAULT_THRESHOLD_VALUE = 300

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

  def self.map_alert_type_label(key)
    case key
    when 'response_time'
      'Tempo de Resposta'
    when 'status_code'
      'Código de Status'
    when 'uptime'
      'Tempo de Atividade'
    else
      'Tipo Desconhecido'
    end
  end

  def frequency_label
    case frequency
    when 'immediate'
      'Imediato'
    when 'every_5_minutes'
      'A cada 5 Minutos'
    when 'every_10_minutes'
      'A cada 10 Minutos'
    when 'every_30_minutes'
      'A cada 30 Minutos'
    when 'hourly'
      'A cada Hora'
    when 'daily'
      'Diário'
    else
      'Frequência desconhecida'
    end
  end

  def self.map_frequency_label(frequency)
    case frequency
    when 'immediate'
      'Imediato'
    when 'every_5_minutes'
      'A cada 5 Minutos'
    when 'every_10_minutes'
      'A cada 10 Minutos'
    when 'every_30_minutes'
      'A cada 30 Minutos'
    when 'hourly'
      'A cada Hora'
    when 'daily'
      'Diário'
    else
      'Frequência desconhecida'
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

  def threshold_value_validation
    case alert_type
    when 'status_code'
      unless valid_status_code?(threshold_value)
        errors.add(:threshold_value, 'deve ser um código de status HTTP válido (100 a 599)')
      end
    when 'response_time'
      errors.add(:threshold_value, 'deve ser um valor numérico maior que zero') unless threshold_value&.to_i&.> 0

      if threshold_value.to_i < 1 || threshold_value.to_i > 5000
        errors.add(:threshold_value, 'deve ser um valor numérico entre 1 e 5000 ms')
      end
    when 'uptime'
      unless threshold_value&.to_i&.between?(0, 100)
        errors.add(:threshold_value,
                   'deve ser um percentual entre 0 e 100')
      end
    end
  end

  # Verifica se o código de status HTTP é válido
  def valid_status_code?(value)
    value.to_s.match?(/\A[1-5][0-9]{2}\z/) # Regex para códigos de status entre 100 e 599
  end
end
