class SitesController < ApplicationController
  before_action :set_site, only: %i[show update destroy edit]

  # GET /sites
  def index
    @sites = current_user.sites
    @inactivated_sites = @sites.where.not(status: :online).count
    @average_response_time_for_all_sites = current_user.average_response_time_for_all_sites
    @uptime_geral = Site.uptime_geral(@sites)&.round(2)
  end

  # GET /sites/1
  def show
  end

  def new
    @site = Site.new
  end

  def edit
    redirect_to sites_path, alert: 'Você não tem permissão para realizar essa operação.'
  end

  # POST /sites
  def create
    # Normaliza a URL
    normalized_url = normalize_url(site_params[:url])
    @site = Site.find_or_initialize_by(url: normalized_url)

    if @site.new_record?
      # Novo site, associa o usuário e salva
      @site.assign_attributes(site_params.merge(current_user: current_user))
      @site.save! # Criação do site e do UserSite no after_create

      redirect_to sites_path, notice: I18n.t('site.create_site_success')
    else
      # Site já existente, associa o usuário
      user_site = UserSite.find_or_initialize_by(user: current_user, site: @site)

      if user_site.new_record?
        user_site.save
        redirect_to sites_path, notice: I18n.t('site.create_site_success')
      else
        redirect_to sites_path, alert: I18n.t('site.site_already_exists')
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    # Exibe os erros de validação, se houver
    redirect_to new_site_path, alert: e.record.errors.full_messages.join(', ')
  end

  # PATCH/PUT /sites/1
  def update
    if @site.update(site_params)
      redirect_to sites_path, notice: I18n.t('notice.update_site_sucess')
    else
      redirect_to edit_site_path(@site.uuid), alert: @site.record.errors.full_messages.join(', ')
    end
  end

  # DELETE /sites/1
  def destroy
    user_site = UserSite.find_by(user: current_user, site: @site)

    if user_site.present?
      user_site.destroy
      redirect_to sites_path, notice: I18n.t('notice.delete_site_sucess')
    else
      # Se o vínculo não existir, o usuário não tem permissão para excluir
      redirect_to sites_path, alert: 'Você não tem permissão para excluir este site'
    end
  rescue ActiveRecord::RecordNotFound => e
    redirect_to sites_path, alert: 'O site não foi encontrado ou você não tem permissão para excluí-lo'
  end

  def send_extract_xlsx_mailer
    current_user.send_extract_xlsx_mailer
    redirect_to sites_path,
                notice: 'Seu relatório está sendo gerado em segundo plano. Você receberá um e-mail assim que estiver concluído.'
  end

  private

  def normalize_url(url)
    return if url.blank?

    uri = URI.parse(url)
    uri.path = '' # Remove qualquer caminho ou barra final
    uri.to_s.chomp('/')
  rescue URI::InvalidURIError
    nil
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_site
    @site = Site.find_by(uuid: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def site_params
    # Normalizando a URL antes de passar para o método permit
    normalized_url = normalize_url(params[:site][:url])

    # Modificando o valor da URL dentro de params[:site]
    params[:site][:url] = normalized_url

    # Permitir os parâmetros do site
    params.require(:site).permit(:url, :user_id)
  end
end
