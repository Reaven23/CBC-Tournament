class TournamentsController < ApplicationController
  def index
    @tournaments = Tournament.includes(:user, :pools, :teams)
                            .where(status: ['active', 'completed'])
                            .order(created_at: :desc)
  end

  def show
    @tournament = Tournament.includes(:pools, :teams, :games).find(params[:id])
    @pools = @tournament.pools.ordered.includes(:teams)
    @games = @tournament.games.includes(:home_team, :away_team, :winner).order(:type, :round_number)
  end
end
