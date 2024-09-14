# spec/models/notification_spec.rb

require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:user) { create(:user) }
  let(:site) { double('site') }

  it 'não permite duplicar notification_method para o mesmo usuário' do
    user = create(:user)
    create(:notification, user: user, notification_method: :email)

    duplicate_notification = build(:notification, user: user, notification_method: :email)

    expect(duplicate_notification).not_to be_valid
    expect(duplicate_notification.errors[:notification_method]).to include('Método de notificação já cadastrado')
  end

  describe '#perform' do
    it 'usa a estratégia de email quando notification_method for email' do
      notification = create(:notification, user: user, notification_method: :email)

      expect(NotificationService::EmailNotification).to receive(:new).and_call_original
      expect_any_instance_of(NotificationService::NotificationSender).to receive(:execute).with(notification, site)

      notification.perform(site)
    end
  end

  it 'incrementa notification_receipts_count' do
    notification = create(:notification, user: user, notification_receipts_count: 0)

    expect do
      notification.increment_notification_receipts_count
    end.to change { notification.notification_receipts_count }.by(1)
  end

  describe '#threshold_value_label' do
    it 'retorna valor com ms para response_time' do
      notification = create(:notification, user: user, alert_type: :response_time, threshold_value: 500)
      expect(notification.threshold_value_label).to eq('500 ms')
    end

    it 'retorna valor de status_code corretamente' do
      notification = create(:notification, user: user, alert_type: :status_code, threshold_value: 200)
      expect(notification.threshold_value_label).to eq('Status: 200')
    end

    it 'retorna valor percentual para uptime' do
      notification = create(:notification, user: user, alert_type: :uptime, threshold_value: 99)
      expect(notification.threshold_value_label).to eq('99%')
    end
  end
end
