require 'rails_helper'
require 'rubyXL'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = FactoryBot.build(:user)
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      user = FactoryBot.build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid without a password' do
      user = FactoryBot.build(:user, password: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid if password and password_confirmation do not match' do
      user = FactoryBot.build(:user, password_confirmation: 'mismatch')
      expect(user).not_to be_valid
    end
  end

  describe 'creation' do
    it 'creates a user with email and password' do
      expect do
        FactoryBot.create(:user)
      end.to change(User, :count).by(1)
    end
  end

  describe '#create_xlsx_extract_file' do
    let(:user) { create(:user, plan: Plan.last) }
    let!(:sites) do
      [
        create(:site, url: 'http://example.com', status: :online)
      ]
    end

    before do
      allow(user).to receive(:sites).and_return(sites)
    end

    it 'gera um arquivo XLSX com as informações corretas' do
      result = user.create_xlsx_extract_file

      # Usar um arquivo temporário para armazenar o conteúdo gerado
      Tempfile.create(['test', '.xlsx']) do |tempfile|
        tempfile.binmode
        tempfile.write(result.read)
        tempfile.rewind

        workbook = RubyXL::Parser.parse(tempfile.path)
        worksheet = workbook.worksheets[0]

        rows = worksheet.map do |row|
          row.cells.map { |cell| cell.value.to_s }
        end

        expect(rows[0]).to eq(['URL', 'Status', 'Tempo Médio de Resposta', 'Porcentagem de Tempo de Atividade',
                               'Data de Criação'])
        expect(rows[1][2]).to match(/\d+ ms/)
        expect(rows[1][0]).to eq('http://example.com')
        expect(rows[1][1]).to eq('Ligado')
        expect(rows[1][3]).to eq('100.0%')
      end
    end
  end
end
