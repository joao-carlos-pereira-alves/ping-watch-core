# frozen_string_literal: true

class Site < ApplicationRecord
  require 'net/http'

  has_many :site_checks, dependent: :destroy
  has_many :user_sites, dependent: :destroy
  has_many :users, through: :user_sites

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp, message: 'Url inválida' },
                  uniqueness: { message: 'URL já cadastrada' }

  enum status: {
    unknown: 0,
    online: 1,
    offline: 2,
    timeout: 3,
    maintenance: 4,
    forbidden: 5
  }

  before_create :update_uuid
  after_create :create_user_site
  after_create :check_site_status
  after_update :perform_notifications, if: :status_changed?

  attr_accessor :current_user

  def average_response_time
    site_checks.average(:response_time_ms)&.to_f&.round(2)
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

  def site_status_distribution
    # Contar a quantidade de cada status
    status_counts = site_checks.group(:check_status).count

    # Definir cores para cada status
    status_colors = {
      'unknown' => '#6c757d',   # Cinza para Unknown
      'online' => '#28a745',    # Verde para Online
      'offline' => '#dc3545',   # Vermelho para Offline
      'timeout' => '#ffc107',   # Amarelo para Timeout
      'maintenance' => '#17a2b8', # Azul para Maintenance
      'forbidden' => '#fd7e14' # Laranja para Forbidden
    }

    # Ordenar os dados por status
    sorted_status_counts = status_counts.sort_by { |status, _| status }.to_h

    {
      labels: sorted_status_counts.keys.map(&:capitalize), # Labels dos status
      datasets: [
        {
          label: I18n.t('chart.site_status_distribution'), # Título do gráfico
          backgroundColor: sorted_status_counts.keys.map { |status| status_colors[status] }, # Cores baseadas no status
          borderColor: sorted_status_counts.keys.map { |status| status_colors[status] }, # Cores das bordas
          data: sorted_status_counts.values # Quantidade de checagens para cada status
        }
      ]
    }
  end

  def uptime_percentage
    total_checks = site_checks.count
    return 0 if total_checks.zero?

    checks_ligado = site_checks.where(check_status: :online).count

    ((checks_ligado.to_f / total_checks) * 100).round(1)
  end

  def self.uptime_geral(sites)
    total_sites = sites.count
    return 0 if total_sites.zero?

    total_uptime = all.map(&:uptime_percentage).sum
    total_uptime / total_sites
  end

  def check_site_status
    uri = URI.parse(url)
    hostname = uri&.hostname
    status = :unknown # Default status in case of unexpected errors
    response_time = nil

    begin
      start_time = Time.now
      Timeout.timeout(10) do
        response = Net::HTTP.get_response(uri)
        response_time = ((Time.now - start_time) * 1000).to_i # Calculate response time in ms

        status = case response
                 when Net::HTTPSuccess
                   # Check for maintenance mode by inspecting response body
                   if maintenance_mode?(response.body)
                     :maintenance
                   else
                     :online
                   end
                 when Net::HTTPForbidden
                   :forbidden
                 else
                   :offline
                 end
      end
    rescue Timeout::Error
      status = :timeout
      response_time = 10_000
    rescue StandardError => e
      status = :unknown
      puts "Error: #{e.message}"
    ensure
      site_checks.create(check_status: status, response_time_ms: response_time)
      save_site(status, hostname)
    end
  end

  def maintenance_mode?(body)
    body.include?('Maintenance') || body.include?('Under Maintenance')
  end

  def save_site(status, hostname)
    update(status: status, hostname: hostname)
  end

  def status_label
    I18n.t("activerecord.attributes.site.status.#{status}")
  end

  def status_class
    case status
    when 'online'
      'badge-success'
    when 'offline', ''
      'badge-danger'
    when 'timeout', 'maintenance', 'forbidden'
      'badge-warning'
    else
      'badge-secondary'
    end
  end

  private

  def create_user_site
    return unless current_user

    UserSite.create(user: current_user, site: self)
  end

  def update_uuid
    self.uuid = SecureRandom.uuid
  end

  def perform_notifications
    users.each do |user|
      user.notifications.each do |notification|
        notification.perform(self)
      end
    end
  end

  def status_changed?
    saved_change_to_status?
  end
end
