class CheckSiteStatusJob < ApplicationJob
  queue_as :default

  def perform(site_id)
    site = Site.find(site_id)
    site.check_site_status
  rescue StandardError => e
    Rails.logger.error "Failed to check status for site #{site_id}: #{e.message}"
  end
end