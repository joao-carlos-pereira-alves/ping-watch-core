class SitesController < ApplicationController
  before_action :set_site, only: %i[show update destroy]

  # GET /sites
  def index
    @sites = Site.where(user: current_user)
    @inactivated_sites = @sites.where.not(status: :online).count
    @average_response_time_for_all_sites = current_user.average_response_time_for_all_sites
    @uptime_geral = Site.uptime_geral(@sites)&.round(2)
  end

  # GET /sites/1
  def show; end

  def new
    @site = Site.new
  end

  # POST /sites
  def create
    @site = Site.new(site_params)

    if @site.save
      redirect_to sites_path, notice: I18n.t('notice.create_site_sucess')
    else
      redirect_to new_site_path
    end
  end

  # PATCH/PUT /sites/1
  def update
    if @site.update(site_params)
      redirect_to sites_path, notice: I18n.t('notice.update_site_sucess')
    else
      redirect_to edit_site_path(@site.uuid)
    end
  end

  # DELETE /sites/1
  def destroy
    if @site&.destroy
      redirect_to sites_path, notice: I18n.t('notice.delete_site_sucess') # No content response indicates successful deletion
    else
      redirect_to sites_path, alert: 'Não foi possível realizar a exclusão deste site' # Respond with 404 Not Found if the record doesn't exist
    end
  end

  def send_extract_xlsx_mailer
    current_user.send_extract_xlsx_mailer
    redirect_to sites_path,
                notice: 'Seu relatório está sendo gerado em segundo plano. Você receberá um e-mail assim que estiver concluído.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_site
    @site = Site.find_by(uuid: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def site_params
    params[:site][:user_id] = current_user.id if params && params[:site].present?
    params.require(:site).permit(:url, :user_id)
  end
end
