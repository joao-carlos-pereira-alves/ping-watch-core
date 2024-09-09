# frozen_string_literal: true

class Site < ApplicationRecord
  require 'net/http'

  has_many :site_checks, dependent: :destroy
  belongs_to :user

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

  after_create_commit :check_site_status
  before_create :update_uuid
  after_update :send_status_change_email, if: :status_changed?

  def average_response_time
    site_checks.average(:response_time_ms)&.to_f&.round(2)
  end

  def uptime_percentage
    total_checks = site_checks.count
    return 0 if total_checks.zero?

    checks_ligado = site_checks.where(check_status: :online).count
    (checks_ligado.to_f / total_checks) * 100
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

      # Save the status to your database or file
      save_user(status, hostname)
    end
  end

  def maintenance_mode?(body)
    # Basic example: Look for a keyword or phrase indicating maintenance
    body.include?('Maintenance') || body.include?('Under Maintenance')
  end

  def save_user(status, hostname)
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

  def update_uuid
    self.uuid = SecureRandom.uuid
  end

  # Método chamado após a atualização do registro
  def send_status_change_email
    SiteMailer.status_change_email(self).deliver_later
  end

  # Verifica se o status mudou
  def status_changed?
    saved_change_to_status?
  end
end
