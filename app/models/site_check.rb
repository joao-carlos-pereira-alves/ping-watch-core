# frozen_string_literal: true

class SiteCheck < ApplicationRecord
  belongs_to :site

  enum check_status: {
    unknown: 0,
    online: 1,
    offline: 2,
    timeout: 3,
    maintenance: 4,
    forbidden: 5
  }, _prefix: :check

  validates :check_status, presence: true
  validates :response_time_ms, numericality: { greater_than_or_equal_to: 0 }
end
