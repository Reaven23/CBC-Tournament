class TournamentsController < ApplicationController
  def index
    @tournaments = Tournament.includes(:user, :pools, :teams)
                            .where(status: ['active', 'completed'])
                            .order(created_at: :desc)
  end

  def show
    @tournament = Tournament.includes(:pools, :teams, :games, :referees).find(params[:id])
    @pools = @tournament.pools.ordered.includes(:teams)

    # Organiser les matchs par type et poule
    @pool_games = @tournament.pool_games
                            .includes(:home_team, :away_team, :winner, :referees, :pool)
                            .order(:pool_id, :round_number)

    @knockout_games = @tournament.knockout_games
                                .includes(:home_team, :away_team, :winner, :referees)
                                .order(:game_type, :round_number)

    # Grouper les matchs de poule par poule
    @games_by_pool = @pool_games.group_by(&:pool)

    # Calculer les classements pour chaque poule
    @pool_standings = {}
    @pools.each do |pool|
      @pool_standings[pool] = pool.standings
    end
  end
end
