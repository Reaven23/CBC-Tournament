class Admin::UsersController < Admin::BaseController
  before_action :authorize_super_admin!

  def index
    @users = User.order(created_at: :desc)
    @tournaments = Tournament.order(created_at: :desc)
  end

  def new
    @user = User.new(role: 'organizer')
    @tournaments = Tournament.order(created_at: :desc)
  end

  def create
    @user = User.new(user_params)
    @user.role = 'organizer'

    if @user.save
      # Assign tournament if provided
      if params[:user][:tournament_id].present?
        tournament = Tournament.find_by(id: params[:user][:tournament_id])
        tournament.update(user: @user) if tournament.present?
      end
      redirect_to admin_users_path, notice: 'Organisateur créé et assigné avec succès.'
    else
      @tournaments = Tournament.order(created_at: :desc)
      flash.now[:alert] = 'Impossible de créer cet utilisateur.'
      render :new, status: :unprocessable_entity
    end
  end

  private

  def authorize_super_admin!
    return if current_user&.super_admin?
    redirect_to admin_root_path, alert: 'Accès réservé aux super administrateurs.'
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
