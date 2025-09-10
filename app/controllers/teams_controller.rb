class TeamsController < ApplicationController
  def show
    @team = Team.includes(:tournament, :pool, :home_games, :away_games, :won_games).find(params[:id])
    @tournament = @team.tournament

    # Récupérer tous les matchs de l'équipe
    @games = @team.games
                  .includes(:home_team, :away_team, :winner, :referees, :pool)
                  .order(:game_type, :round_number)

    # Séparer les matchs par type
    @pool_games = @games.where(game_type: 'pool')
    @knockout_games = @games.where(game_type: %w[quarter semi final third_place])

    # Statistiques de l'équipe
    @stats = {
      total_games: @team.total_games,
      wins: @team.wins,
      losses: @team.losses,
      goals_scored: @team.goals_scored,
      goals_conceded: @team.goals_conceded,
      goal_difference: @team.goal_difference,
      points: @team.points
    }
  end
end
