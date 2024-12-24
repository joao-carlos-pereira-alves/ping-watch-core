# frozen_string_literal: true

# lib/notification_service/notification_sender.rb
module NotificationService
  class NotificationSender
    def initialize(strategy)
      @strategy = strategy
    end

    def execute(notification, recipient, _user = nil)
      @strategy.send(notification, recipient, _user)
    end
  end
end
