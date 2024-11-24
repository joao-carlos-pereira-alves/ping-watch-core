# frozen_string_literal: true

# lib/notification_service/notification_strategy.rb
module NotificationService
  class NotificationStrategy
    def send(notification, recipient, user = nil)
      raise NotImplementedError, 'This method should be overridden by subclasses'
    end
  end
end
