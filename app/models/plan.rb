# frozen_string_literal: true

class Plan < ApplicationRecord
  has_many :users, dependent: :nullify

  enum name: {
    free: 0,
    basic: 1,
    gold: 2
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
      'Suporte 24/7',
      'Notificações customizadas e ilimitadas'
    ]
  }.freeze

  def benefits
    BENEFITS[name.to_sym] || []
  end
end
