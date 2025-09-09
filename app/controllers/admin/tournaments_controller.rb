class Admin::TournamentsController < Admin::BaseController
  before_action :set_tournament, only: [:show, :edit, :update, :destroy, :generate_quarters, :delete_quarters, :generate_semis, :delete_semis, :generate_finals, :delete_finals, :create_pools, :generate_pool_games]
  before_action :authorize_tournament_management!, only: [:show, :edit, :update, :destroy, :generate_quarters, :delete_quarters, :generate_semis, :delete_semis, :generate_finals, :delete_finals, :create_pools, :generate_pool_games]

  def index
    @tournaments = if current_user.super_admin?
                     Tournament.includes(:user, :pools, :teams).order(created_at: :desc)
                   else
                     current_user.tournaments.includes(:pools, :teams).order(created_at: :desc)
                   end
  end

  def show
    @pools = @tournament.pools.ordered.includes(teams: { photo_attachment: :blob })
    @games = @tournament.games.includes(:home_team, :away_team, :winner).order(:game_type, :round_number)
    @teams = @tournament.teams.includes(:pool, photo_attachment: :blob)
  end

  def new
    @tournament = Tournament.new
  end

  def create
    @tournament = current_user.tournaments.build(tournament_params)
    @tournament.status = 'draft' # Valeur par défaut

    if @tournament.save
      redirect_to admin_tournament_path(@tournament), notice: 'Tournoi créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tournament.update(tournament_params)
      redirect_to admin_tournament_path(@tournament), notice: 'Tournoi mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    @tournament.destroy
    redirect_to admin_tournaments_path, notice: 'Tournoi supprimé avec succès.'
  end

  def generate_quarters
    if @tournament.can_generate_quarters?
      @tournament.generate_quarter_finals
      redirect_to admin_tournament_path(@tournament), notice: 'Quarts de finale générés avec succès.'
    else
      redirect_to admin_tournament_path(@tournament), alert: 'Impossible de générer les quarts de finale.'
    end
  end

  def delete_quarters
    if @tournament.can_delete_quarters?
      @tournament.delete_quarter_finals
      redirect_to admin_tournament_path(@tournament), notice: 'Quarts de finale supprimés avec succès.'
    else
      redirect_to admin_tournament_path(@tournament), alert: 'Impossible de supprimer les quarts de finale.'
    end
  end

  def generate_semis
    if @tournament.can_generate_semis?
      @tournament.generate_semi_finals
      redirect_to admin_tournament_path(@tournament), notice: 'Demi-finales générées avec succès.'
    else
      redirect_to admin_tournament_path(@tournament), alert: 'Impossible de générer les demi-finales.'
    end
  end

  def generate_finals
    if @tournament.can_generate_finals?
      @tournament.generate_finals
      if @tournament.has_third_place? && @tournament.can_generate_third_place?
        @tournament.generate_third_place
      end
      redirect_to admin_tournament_path(@tournament), notice: 'Finales générées avec succès.'
    else
      redirect_to admin_tournament_path(@tournament), alert: 'Impossible de générer les finales.'
    end
  end

  def create_pools
    if @tournament.pools.empty?
      @tournament.create_pools_and_distribute_teams
      redirect_to admin_tournament_path(@tournament), notice: 'Poules créées avec succès.'
    else
      redirect_to admin_tournament_path(@tournament), alert: 'Les poules existent déjà.'
    end
  end

  def generate_pool_games
    if @tournament.can_generate_pool_games?
      @tournament.generate_pool_games
      redirect_to admin_tournament_path(@tournament), notice: 'Matchs de poule générés avec succès.'
    else
      redirect_to admin_tournament_path(@tournament), alert: 'Impossible de générer les matchs de poule.'
    end
  end

  def delete_semis
    if @tournament.can_delete_semis?
      @tournament.delete_semi_finals
      redirect_to admin_tournament_path(@tournament), notice: 'Demi-finales supprimées avec succès.'
    else
      redirect_to admin_tournament_path(@tournament), alert: 'Impossible de supprimer les demi-finales.'
    end
  end

  def delete_finals
    if @tournament.can_delete_finals?
      @tournament.delete_finals
      redirect_to admin_tournament_path(@tournament), notice: 'Finales supprimées avec succès.'
    else
      redirect_to admin_tournament_path(@tournament), alert: 'Impossible de supprimer les finales.'
    end
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

  def tournament_params
    params.require(:tournament).permit(:name, :description, :start_date, :end_date, :max_teams, :has_third_place)
  end
end
