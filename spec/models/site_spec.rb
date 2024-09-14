# spec/models/site_spec.rb

require 'rails_helper'

RSpec.describe Site, type: :model do
  let(:user) { create(:user) }
  let(:site) { create(:site, user: user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_uniqueness_of(:url).with_message('URL já cadastrada') }
    it { is_expected.to allow_value('http://example.com').for(:url) }
    it { is_expected.not_to allow_value('invalid_url').for(:url).with_message('Url inválida') }
  end

  describe 'associations' do
    it { is_expected.to have_many(:site_checks).dependent(:destroy) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'callbacks' do
    let(:site) { create(:site, status: :online) }

    it 'calls perform_notifications after update if status changed' do
      expect(site).to receive(:perform_notifications)
      site.update!(status: :offline) # Simulando a mudança de status
    end
  end

  describe '#site_checks_by_hour_of_day' do
    it 'returns a hash with site checks grouped by hour of the day' do
      create(:site_check, site: site, created_at: '2023-09-14 08:00:00')
      create(:site_check, site: site, created_at: '2023-09-14 08:30:00')
      create(:site_check, site: site, created_at: '2023-09-14 09:00:00')

      result = site.site_checks_by_hour_of_day
      expect(result[:labels]).to include('08:00', '09:00')
      expect(result[:datasets].first[:data]).to include(2, 1)
    end
  end

  describe '#site_status_distribution' do
    it 'returns a hash with status distribution and their colors' do
      create(:site_check, site: site, check_status: 'online')
      create(:site_check, site: site, check_status: 'offline')

      result = site.site_status_distribution
      expect(result[:labels]).to include('Online', 'Offline')
      expect(result[:datasets].first[:data]).to include(1, 1)
    end
  end

  describe '#uptime_percentage' do
    it 'calculates the uptime percentage based on site checks' do
      create(:site_check, site: site, check_status: 'online')
      create(:site_check, site: site, check_status: 'offline')

      expect(site.uptime_percentage).to eq(66.7)
    end
  end

  describe 'private methods' do
    describe '#update_uuid' do
      it 'generates a UUID before creation' do
        site = build(:site, uuid: nil)
        expect { site.save }.to change { site.uuid }.from(nil)
      end
    end
  end

  describe '#status_class' do
    subject { site_check.status_class }

    let(:site_check) { described_class.new(status: status) }

    context 'when status is online' do
      let(:status) { 'online' }

      it { is_expected.to eq('badge-success') }
    end

    context 'when status is offline' do
      let(:status) { 'offline' }

      it { is_expected.to eq('badge-danger') }
    end

    context 'when status is an empty string' do
      let(:status) { '' }

      it { is_expected.to eq('badge-secondary') }
    end

    context 'when status is timeout' do
      let(:status) { 'timeout' }

      it { is_expected.to eq('badge-warning') }
    end

    context 'when status is maintenance' do
      let(:status) { 'maintenance' }

      it { is_expected.to eq('badge-warning') }
    end

    context 'when status is forbidden' do
      let(:status) { 'forbidden' }

      it { is_expected.to eq('badge-warning') }
    end

    context 'when status is unknown' do
      let(:status) { 'unknown' }

      it { is_expected.to eq('badge-secondary') }
    end
  end
end
