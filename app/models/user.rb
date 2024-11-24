# frozen_string_literal: true

class User < ApplicationRecord
  has_many :user_sites, dependent: :destroy
  has_many :sites, through: :user_sites
  has_many :notifications, dependent: :destroy
  belongs_to :plan, optional: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true
  validates :password, presence: true, length: { minimum: 6 }

  after_create :create_notification
  after_create :create_plan

  def average_response_time_for_all_sites
    site_checks
      .average(:response_time_ms)
      .to_f
      .round(2)
  end

  def group_sites_per_status
    statuses = sites.group(:status).count
    statuses.transform_keys { |key| I18n.t("site.status.#{key}") }
  end

  def group_sites_checks_by_hour_of_day
    site_checks
      .group_by_hour_of_day(:created_at, format: '%H:%M').count
  end

  def group_response_time_trend
    response_times = site_checks
                     .group_by_week(:created_at)
                     .average(:response_time_ms)

    rounded_response_times = response_times.transform_values { |v| v.round(0) }

    {
      labels: response_times.keys.map { |date| date.strftime('%d/%m/%Y') }, # Datas formatadas como strings
      datasets: [
        {
          label: I18n.t('chart.sites_checks_response_time_trend'),
          backgroundColor: 'rgba(255, 165, 0, 0.8)', # Verde claro com transparência
          borderColor: '#28a745', # Verde padrão
          data: rounded_response_times.values # Valores das médias de tempo de resposta
        }
      ]
    }
  end

  def create_xlsx_extract_file
    p = Axlsx::Package.new

    p.workbook.add_worksheet(:name => 'Sites') do |sheet|
      sheet.add_row ['URL', 'Status', 'Tempo Médio de Resposta', 'Porcentagem de Tempo de Atividade', 'Data de Criação']

      sites.each do |site|
        sheet.add_row [
          site.url,
          site.status_label,
          "#{site.average_response_time} ms",
          "#{site.uptime_percentage&.round(2)}%",
          site.created_at&.strftime('%d/%m/%Y')
        ]
      end
    end

    p.use_shared_strings = true
    p.to_stream
  end

  def send_extract_xlsx_mailer
    Thread.new do
      SiteMailer.extract_xlsx(self).deliver_later
    end
  end

  def site_check_summary
    data = {}

    sites.find_each do |site|
      check_count = site.site_checks.count
      data[site.hostname] ||= 0
      data[site.hostname] += check_count
    end

    data = data.sort_by { |_, v| v }.reverse.to_h

    {
      labels: data.keys,
      datasets: [
        {
          label: I18n.t('chart.average_response_title'),
          backgroundColor: Array.new(data.keys.size, '#007bff'), # Azul padrão
          borderColor: Array.new(data.keys.size, '#007bff'), # Azul padrão
          data: data.values
        }
      ]
    }
  end

  def average_response_time_per_site
    data = site_checks
           .select('sites.hostname AS hostname, AVG(site_checks.response_time_ms) AS average_response_time')
           .group('sites.hostname')
           .map { |record| { hostname: record.hostname, average_response_time: record.average_response_time.to_f } }

    sorted_data = data.sort_by { |record| record[:average_response_time] }.reverse

    {
      labels: sorted_data.map { |record| record[:hostname] }, # Nomes dos sites
      datasets: [
        {
          label: I18n.t('chart.average_response_title'),
          backgroundColor: '#28a745', # Verde padrão
          borderColor: '#28a745', # Verde padrão
          data: sorted_data.map { |record| record[:average_response_time] } # Tempo médio de resposta
        }
      ]
    }
  end

  def site_status_summary
    data = {}

    sites.find_each do |site|
      # Contando o número de ocorrências para cada status
      status = site.status_label
      data[status] ||= 0
      data[status] += 1
    end

    data = data.sort_by { |_, v| v }.reverse.to_h

    {
      labels: data.keys,
      datasets: [
        {
          label: I18n.t('chart.sites_per_status_title'),
          backgroundColor: Array.new(data.keys.size, '#dc3545'), # Vermelho padrão
          borderColor: Array.new(data.keys.size, '#dc3545'), # Vermelho padrão
          data: data.values
        }
      ]
    }
  end

  def site_checks_by_hour_of_day
    data = site_checks
           .group_by_hour_of_day(:created_at, format: '%H:%M')
           .count

    sorted_data = data.sort_by { |hour, _| hour }.to_h

    {
      labels: sorted_data.keys, # Horas do dia no formato "HH:MM"
      datasets: [
        {
          label: I18n.t('chart.sites_checks_by_hour_of_day'),
          backgroundColor: '#007bff', # Azul padrão
          borderColor: '#007bff', # Azul padrão
          data: sorted_data.values # Quantidade de checagens
        }
      ]
    }
  end

  private

  def site_checks
    SiteCheck
      .joins(:site)
      .where(sites: { id: sites.select(:id) }) # Filtra site_checks pelo id dos sites associados ao usuário
  end

  def create_notification
    Notification.create(user: self, notification_method: :email, alert_type: :response_time, frequency: :hourly,
                        threshold_value: Notification::DEFAULT_THRESHOLD_VALUE)
  end

  def create_plan
    plan = Plan.find_by(name: 'free')

    if plan
      self.plan = plan
      save!
    else
      puts "\n Plano 'free' não encontrado."
      throw(:abort) # Interrompe a criação do usuário
    end
  rescue StandardError => e
    puts "\n Não foi possível cadastrar o usuário em um plano: #{e.message}"
  end
end
