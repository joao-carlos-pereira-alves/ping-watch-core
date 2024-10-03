require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe 'Plan::BENEFITS' do
    let(:expected_free_benefits) { ['Monitoramento básico', '1 site', 'Notificações limitadas'] }
    let(:expected_basic_benefits) { ['Monitoramento avançado', '5 sites', 'Notificações ilimitadas'] }
    let(:expected_gold_benefits) { ['Monitoramento premium', 'Sites ilimitados', 'Suporte 24/7', 'Notificações customizadas e ilimitadas'] }

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
    let(:free_plan) { Plan.new(name: 'free') }
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
end