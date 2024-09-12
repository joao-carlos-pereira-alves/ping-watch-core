# frozen_string_literal: true

# lib/notification_service/notification_sender.rb
module NotificationService
  class NotificationSender
    def initialize(strategy)
      @strategy = strategy
    end

    def execute(notification, recipient)
      @strategy.send(notification, recipient)
    end
  end
end
