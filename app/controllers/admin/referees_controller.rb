class Admin::RefereesController < Admin::BaseController
  before_action :set_tournament
  before_action :set_referee, only: [:edit, :update, :destroy]
  before_action :authorize_tournament_management!

  def index
    @referees = @tournament.referees.order(:first_name, :last_name)
  end

  def new
    @referee = @tournament.referees.build
  end

  def create
    @referee = @tournament.referees.build(referee_params)

    if @referee.save
      redirect_to admin_tournament_referees_path(@tournament), notice: 'Arbitre créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @referee.update(referee_params)
      redirect_to admin_tournament_referees_path(@tournament), notice: 'Arbitre modifié avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @referee.destroy
    redirect_to admin_tournament_referees_path(@tournament), notice: 'Arbitre supprimé avec succès.'
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def set_referee
    @referee = @tournament.referees.find(params[:id])
  end

  def referee_params
    params.require(:referee).permit(:first_name, :last_name, :email, :phone)
  end
end
