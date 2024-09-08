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
      redirect_to dashboard_index_path, notice: I18n.t('notice.notice_create_site_sucess')
    else
      redirect_to new_site_path
    end
  end

  # PATCH/PUT /sites/1
  def update
    if @site.update(site_params)
      @site
    else
      render json: @site.errors, status: :unprocessable_entity
    end
  end

  # DELETE /sites/1
  def destroy
    if @site
      @site.destroy
      head :no_content # No content response indicates successful deletion
    else
      head :not_found # Respond with 404 Not Found if the record doesn't exist
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
    params[:site][:user_id] = current_user.id
    params.require(:site).permit(:url, :user_id)
  end
end
