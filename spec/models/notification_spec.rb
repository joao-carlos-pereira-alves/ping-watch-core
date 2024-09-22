# spec/models/notification_spec.rb

require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:site) { create(:site) }

  # it 'não permite duplicar notification_method para o mesmo usuário' do
  #   user = create(:user, email: Faker::Internet.email)

  #   # create(:notification, user: user, notification_method: :email,
  #   #                       threshold_value: Notification::DEFAULT_THRESHOLD_VALUE, frequency: :hourly)

  #   duplicate_notification = build(:notification, user: user, notification_method: :email,
  #                                                 threshold_value: Notification::DEFAULT_THRESHOLD_VALUE, frequency: :hourly)

  #   expect(duplicate_notification).not_to be_valid
  #   expect(duplicate_notification.errors[:notification_method]).to include('Método de notificação já cadastrado')
  # end

  # describe '#perform' do
  #   it 'usa a estratégia de email quando notification_method for email' do
  #     user = create(:user, email: Faker::Internet.email)
  #     notification = build(:notification, user: user, notification_method: :email,
  #                                         threshold_value: Notification::DEFAULT_THRESHOLD_VALUE, frequency: :hourly)

  #     expect(NotificationService::EmailNotification).to receive(:new).and_call_original
  #     expect_any_instance_of(NotificationService::NotificationSender).to receive(:execute).with(notification, site)

  #     notification.perform(site)
  #   end
  # end

  # it 'incrementa notification_receipts_count' do
  #   user = create(:user, email: Faker::Internet.email)
  #   notification = build(:notification, user: user, notification_receipts_count: 0, notification_method: :email,
  #                                       threshold_value: Notification::DEFAULT_THRESHOLD_VALUE, frequency: :hourly)

  #   expect do
  #     notification.increment_notification_receipts_count
  #   end.to change { notification.notification_receipts_count }.by(1)
  # end

  # describe '#threshold_value_label' do
  #   it 'retorna valor com ms para response_time' do
  #     user = create(:user, email: Faker::Internet.email)
  #     notification = create(:notification, user: user, alert_type: :response_time, threshold_value: '500', notification_method: :email,
  #                                          frequency: :hourly)
  #     expect(notification.threshold_value_label).to eq('500 ms')
  #   end

  #   it 'retorna valor de status_code corretamente' do
  #     user = create(:user, email: Faker::Internet.email)
  #     notification = create(:notification, user: user, alert_type: :status_code, threshold_value: '200',
  #                                          frequency: :hourly)
  #     expect(notification.threshold_value_label).to eq('Status: 200')
  #   end

  #   it 'retorna valor percentual para uptime' do
  #     user = create(:user, email: Faker::Internet.email)
  #     notification = create(:notification, user: user, alert_type: :uptime, threshold_value: '99', frequency: :hourly,
  #                                          notification_method: :email)
  #     expect(notification.threshold_value_label).to eq('99%')
  #   end
  # end

  describe '#status_from_code' do
    context 'when alert_type is not status_code' do
      it 'returns nil and prints an error message' do
        allow(subject).to receive(:alert_type).and_return('response_time')
        expect(subject.status_from_code).to be_nil
      end
    end

    context 'when alert_type is status_code' do
      before { allow(subject).to receive(:alert_type).and_return('status_code') }

      it 'returns online for status between 200 and 299' do
        allow(subject).to receive(:threshold_value).and_return('200')
        expect(subject.status_from_code).to eq('online')

        allow(subject).to receive(:threshold_value).and_return('299')
        expect(subject.status_from_code).to eq('online')
      end

      it 'returns forbidden for status 403' do
        allow(subject).to receive(:threshold_value).and_return('403')
        expect(subject.status_from_code).to eq('forbidden')
      end

      it 'returns maintenance for status 503' do
        allow(subject).to receive(:threshold_value).and_return('503')
        expect(subject.status_from_code).to eq('maintenance')
      end

      it 'returns timeout for status 504' do
        allow(subject).to receive(:threshold_value).and_return(504)
        expect(subject.status_from_code).to eq('timeout')
      end

      it 'returns unknown for status 520' do
        allow(subject).to receive(:threshold_value).and_return(520)
        expect(subject.status_from_code).to eq('unknown')
      end

      it 'returns unknown for unrecognized status' do
        allow(subject).to receive(:threshold_value).and_return(600)
        expect(subject.status_from_code).to eq('unknown')
      end
    end
  end

  describe '#can_notify?' do
    context 'when alert_type is not present' do
      it 'returns false' do
        allow(subject).to receive(:alert_type).and_return(nil)
        expect(subject.can_notify?).to be_falsey
      end
    end

    context 'when alert_type is response_time' do
      before { allow(subject).to receive(:alert_type).and_return('response_time') }

      it 'returns true if response_time_ms is greater than or equal to threshold_value' do
        allow(subject).to receive(:threshold_value).and_return(100)
        expect(subject.can_notify?(150)).to be_truthy
      end

      it 'returns false if response_time_ms is less than threshold_value' do
        allow(subject).to receive(:threshold_value).and_return(200)
        expect(subject.can_notify?(150)).to be_falsey
      end
    end

    context 'when alert_type is status_code' do
      before { allow(subject).to receive(:alert_type).and_return('status_code') }

      it 'returns true if status_from_code matches check_status' do
        allow(subject).to receive(:status_from_code).and_return('online')
        expect(subject.can_notify?(nil, 'online')).to be_truthy
      end

      it 'returns false if status_from_code does not match check_status' do
        allow(subject).to receive(:status_from_code).and_return('offline')
        expect(subject.can_notify?(nil, 'online')).to be_falsey
      end
    end
  end
end
