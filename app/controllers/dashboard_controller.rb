# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @orders = Order.by_date(params[:by_date])
                   .by_product_name(params[:by_product_name])
                   .order(:created_at)

    @order_items = OrderItem.where(order_id: @orders)

    service = DashboardService.new(@orders)

    @group_response_time_trend = current_user.group_response_time_trend
    @site_checks_by_hour_of_day = current_user.site_checks_by_hour_of_day
    @site_status_summary = current_user.site_status_summary
    @average_response_time_per_site = current_user.average_response_time_per_site
    @sites = Site.where(user: current_user)
    @inactivated_sites = @sites.where.not(status: :online).count
    @average_response_time_for_all_sites = current_user.average_response_time_for_all_sites
    @uptime_geral = Site.uptime_geral(@sites)&.round(2)
  end

  def send_extract_xlsx_mailer
    current_user.send_extract_xlsx_mailer
    redirect_to dashboard_index_path,
                notice: 'Seu relatório está sendo gerado em segundo plano. Você receberá um e-mail assim que estiver concluído.'
  end
end
