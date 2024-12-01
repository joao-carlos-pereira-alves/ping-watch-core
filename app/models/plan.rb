# frozen_string_literal: true

class Plan < ApplicationRecord
  has_many :users, dependent: :nullify

  enum name: {
    free: 0,
    basic: 1,
    gold: 2
  }

  after_create :set_default_permissions

  PERMISSIONS = {
    free: {
      monitor_sites: true,
      notifications: true,
      max_sites: 1,
      ping_interval: 30,
      detailed_reports: false,
      priority_support: false
    },
    basic: {
      monitor_sites: true,
      notifications: true,
      max_sites: 5,
      ping_interval: 15,
      detailed_reports: true,
      priority_support: false
    },
    gold: {
      monitor_sites: true,
      notifications: true,
      max_sites: 20,
      ping_interval: 5,
      detailed_reports: true,
      priority_support: true
    }
  }

  BENEFITS = {
    free: [
      'Monitoramento básico',
      '1 site',
      'Notificações limitadas'
    ],
    basic: [
      'Monitoramento avançado',
      '5 sites',
      'Notificações ilimitadas'
    ],
    gold: [
      'Monitoramento premium',
      'Sites ilimitados',
      'Notificações customizadas e ilimitadas'
    ]
  }.freeze

  validates :name, presence: true, uniqueness: true

  def benefits
    BENEFITS[name.to_sym] || []
  end

  def permissions
    {
      monitor_sites: monitor_sites,
      notifications: notifications,
      max_sites: max_sites,
      ping_interval: ping_interval,
      detailed_reports: detailed_reports,
      priority_support: priority_support
    }
  end

  def permission?(permission)
    permissions[permission] == true
  end

  private

  # Método para definir permissões padrão
  def set_default_permissions
    plan_type = name.downcase.to_sym
    if PERMISSIONS.key?(plan_type)
      update(PERMISSIONS[plan_type])
    end
  end
end
