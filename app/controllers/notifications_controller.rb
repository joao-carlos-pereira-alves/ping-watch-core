class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[show edit update destroy]

  # GET /notifications
  def index
    @notifications = current_user.notifications
    @notification_receipts = NotificationReceipt.where(notification: @notifications)
  end

  # GET /notifications/1
  def show
  end

  # GET /notifications/new
  def new
    @notification = Notification.new
  end

  # GET /notifications/1/edit
  def edit
  end

  # POST /notifications
  def create
    @notification = Notification.new(notification_params)

    if @notification.save
      redirect_to @notification, notice: 'Notification was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /notifications/1
  def update
    if @notification.update(notification_params)
      redirect_to notification_path(@notification.uuid), notice: I18n.t('notification.success_update')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /notifications/1
  def destroy
    @notification.destroy
    redirect_to notifications_url, notice: 'Notification was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_notification
    @notification = Notification.find_by(uuid: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def notification_params
    params.fetch(:notification).permit(:alert_type, :frequency, :threshold_value, :enabled)
  end
end
