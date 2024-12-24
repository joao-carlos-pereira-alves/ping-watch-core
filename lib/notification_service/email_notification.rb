# frozen_string_literal: true

# lib/notification_service/email_notification.rb
module NotificationService
  class EmailNotification < NotificationStrategy
    def send(notification, site, user)
      send_notification(site, user)
      create_notification_receipt(notification)
      update_notification(notification)
    end

    private

    def send_notification(site, user)
      SiteMailer.status_change_email(site, user).deliver_later
    end

    def create_notification_receipt(notification)
      NotificationReceipt.create(
        receipt_number: SecureRandom.uuid,
        sent_at: DateTime.now.in_time_zone('America/Sao_Paulo'),
        notification: notification,
        status: '200',
        notification_method: :email
      )
    end

    def update_notification(notification)
      notification.increment_notification_receipts_count
      notification.last_notified_at = DateTime.now.in_time_zone('America/Sao_Paulo')
      notification.save
    end
  end
end
