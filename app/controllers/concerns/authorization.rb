module Authorization
  extend ActiveSupport::Concern

  private

  def authenticate_user!
    redirect_to new_user_session_path unless user_signed_in?
  end

  def authenticate_super_admin!
    authenticate_user!
    redirect_to root_path, alert: "Accès non autorisé" unless current_user.super_admin?
  end

  def authenticate_organizer_or_super_admin!
    authenticate_user!
    redirect_to root_path, alert: "Accès non autorisé" unless current_user.super_admin? || current_user.organizer?
  end

  def can_manage_tournament?(tournament)
    current_user.super_admin? || tournament.user == current_user
  end

  def authorize_tournament_management!
    redirect_to root_path, alert: "Vous n'avez pas l'autorisation de gérer ce tournoi" unless can_manage_tournament?(@tournament)
  end
end
