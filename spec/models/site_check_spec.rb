# spec/models/site_spec.rb

require 'rails_helper'

RSpec.describe SiteCheck, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      site = FactoryBot.create(:site) # Supondo que você tenha uma fábrica para Site
      site_check = FactoryBot.build(:site_check, site: site)
      expect(site_check).to be_valid
    end

    it 'is not valid without a check_status' do
      site = FactoryBot.create(:site)
      site_check = FactoryBot.build(:site_check, check_status: nil, site: site)
      expect(site_check).not_to be_valid
    end

    it 'is not valid without a response_time_ms' do
      site = FactoryBot.create(:site)
      site_check = FactoryBot.build(:site_check, response_time_ms: nil, site: site)
      expect(site_check).not_to be_valid
    end

    it 'is not valid with a negative response_time_ms' do
      site = FactoryBot.create(:site)
      site_check = FactoryBot.build(:site_check, response_time_ms: -1, site: site)
      expect(site_check).not_to be_valid
    end
  end

  describe 'creation' do
    it 'creates a SiteCheck record' do
      site = FactoryBot.create(:site)
      expect do
        FactoryBot.create(:site_check, site: site)
      end.to change(SiteCheck, :count).by(1)
    end
  end
end
