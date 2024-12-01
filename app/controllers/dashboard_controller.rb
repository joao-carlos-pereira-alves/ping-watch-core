# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :set_filter_params, only: %i[index]

  def index
    @sites = current_user.sites
    @sites = filter_by_domain(@sites, @by_site_domain)
    @sites = filter_by_date(@sites, @by_date)
    filtered_site_checks = SiteCheck.where(site_id: @sites.pluck(:id))
    @group_response_time_trend = current_user.group_response_time_trend(filtered_site_checks)
    @site_checks_by_hour_of_day = current_user.site_checks_by_hour_of_day(filtered_site_checks)
    @site_status_summary = current_user.site_status_summary(@sites)
    @average_response_time_per_site = current_user.average_response_time_per_site(filtered_site_checks)
    @inactivated_sites = @sites.where.not(status: :online).count
    @average_response_time_for_all_sites = current_user.average_response_time_for_all_sites(filtered_site_checks)
    @uptime_geral = Site.uptime_geral(@sites)&.round(2)
  rescue => e
    redirect_to dashboard_index_path, alert: "Ocorreu um erro ao tentar filtrar os dados."
  end

  def send_extract_xlsx_mailer
    current_user.send_extract_xlsx_mailer
    redirect_to dashboard_index_path,
                notice: 'Seu relatório está sendo gerado em segundo plano. Você receberá um e-mail assim que estiver concluído.'
  end

  private

  def set_filter_params
    @by_date = params[:by_date]
    @by_site_domain = params[:by_site_domain]
  end

   # Filtro por data
   def filter_by_date(sites, by_date)
    case by_date
    when 'Último Mês'
      sites.where('created_at >= ?', 1.month.ago)
    when :last_3_months
      sites.where('created_at >= ?', 3.months.ago)
    when :last_5_months
      sites.where('created_at >= ?', 5.months.ago)
    else
      sites
    end
  end

  # Filtro por domínio
  def filter_by_domain(sites, by_site_domain)
    if by_site_domain.present?
      sites.joins(:user_sites).where('user_sites.site_id = sites.id AND sites.url LIKE ?', "%#{by_site_domain}%")
    else
      sites
    end
  end
end
