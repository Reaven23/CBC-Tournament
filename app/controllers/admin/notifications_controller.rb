class Admin::NotificationsController < Admin::BaseController
  before_action :ensure_super_admin

  def index
    @notifications = Notification.recent
  end

  def show
    @notification = Notification.find(params[:id])
  end

  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy
    redirect_to admin_notifications_path, notice: 'Notification supprimée avec succès.'
  end

  private

  def ensure_super_admin
    unless current_user&.super_admin?
      redirect_to admin_root_path, alert: 'Accès non autorisé. Seuls les super administrateurs peuvent accéder à cette section.'
    end
  end
end
