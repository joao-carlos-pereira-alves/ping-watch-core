require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe 'Plan::BENEFITS' do
    let(:expected_free_benefits) { ['Monitoramento básico', '1 site', 'Notificações limitadas'] }
    let(:expected_basic_benefits) { ['Monitoramento avançado', '5 sites', 'Notificações ilimitadas'] }
    let(:expected_gold_benefits) { ['Monitoramento premium', 'Sites ilimitados', 'Notificações customizadas e ilimitadas'] }

    it 'garante que os benefícios do plano Free não mudaram' do
      expect(Plan::BENEFITS[:free]).to eq(expected_free_benefits)
    end

    it 'garante que os benefícios do plano Basic não mudaram' do
      expect(Plan::BENEFITS[:basic]).to eq(expected_basic_benefits)
    end

    it 'garante que os benefícios do plano Gold não mudaram' do
      expect(Plan::BENEFITS[:gold]).to eq(expected_gold_benefits)
    end
  end

  describe '#benefits' do
    let(:free_plan) { Plan.new(name: :free) }
    let(:basic_plan) { Plan.new(name: 'basic') }
    let(:gold_plan) { Plan.new(name: 'gold') }

    it 'retorna os benefícios corretos para o plano Free' do
      expect(free_plan.benefits).to eq(Plan::BENEFITS[:free])
    end

    it 'retorna os benefícios corretos para o plano Basic' do
      expect(basic_plan.benefits).to eq(Plan::BENEFITS[:basic])
    end

    it 'retorna os benefícios corretos para o plano Gold' do
      expect(gold_plan.benefits).to eq(Plan::BENEFITS[:gold])
    end
  end

  describe 'validations' do
    it 'validates presence of name' do
      plan = Plan.new(name: nil)
      expect(plan).not_to be_valid
    end

    it 'validates uniqueness of name' do
      Plan.create!(name: :free)
      duplicate_plan = Plan.new(name: :free)
      expect(duplicate_plan).not_to be_valid
    end
  end

  describe 'after_create callback' do
    it 'sets default permissions for free plan' do
      plan = Plan.create!(name: :free)
      expect(plan.monitor_sites).to be_truthy
      expect(plan.notifications).to be_truthy
      expect(plan.max_sites).to eq(1)
      expect(plan.ping_interval).to eq(30)
      expect(plan.detailed_reports).to be_falsey
      expect(plan.priority_support).to be_falsey
    end

    it 'sets default permissions for basic plan' do
      plan = Plan.create!(name: :basic)
      expect(plan.monitor_sites).to be_truthy
      expect(plan.notifications).to be_truthy
      expect(plan.max_sites).to eq(5)
      expect(plan.ping_interval).to eq(15)
      expect(plan.detailed_reports).to be_truthy
      expect(plan.priority_support).to be_falsey
    end

    it 'sets default permissions for gold plan' do
      plan = Plan.create!(name: :gold)
      expect(plan.monitor_sites).to be_truthy
      expect(plan.notifications).to be_truthy
      expect(plan.max_sites).to eq(20)
      expect(plan.ping_interval).to eq(5)
      expect(plan.detailed_reports).to be_truthy
      expect(plan.priority_support).to be_truthy
    end
  end
end