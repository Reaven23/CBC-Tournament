class NotificationsController < ApplicationController
  def create
    @notification = Notification.new(notification_params)
    @notification.notification_type = 'tournament_organization'
    @notification.message = "Demande d'organisation de tournoi"

    if @notification.save
      redirect_to root_path, notice: 'Votre demande a été envoyée avec succès ! Nous vous contacterons bientôt.'
    else
      redirect_to root_path, alert: 'Une erreur est survenue. Veuillez réessayer.'
    end
  end

  private

  def notification_params
    params.require(:notification).permit(:email)
  end
end
