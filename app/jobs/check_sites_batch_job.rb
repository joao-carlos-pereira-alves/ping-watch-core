# frozen_string_literal: true

class CheckSitesBatchJob < ApplicationJob
  queue_as :check_site_status

  def perform
    Site.find_each do |site|
      check_site_status_for(site)
    end
  rescue StandardError => e
    Rails.logger.error "Failed to check site statuses: #{e.message}"
  end

  private

  def check_site_status_for(site)
    site.check_site_status
  end
end
