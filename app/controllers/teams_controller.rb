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

    # SEO pour la page de l'équipe
    @page_title = "#{@team.name} - #{@tournament.name}"
    @meta_description = "Découvrez l'équipe #{@team.name} du tournoi #{@tournament.name}. #{@stats[:wins]} victoires, #{@stats[:losses]} défaites. #{@stats[:goals_scored]} points marqués, #{@stats[:goals_conceded]} points encaissés. Suivez tous les matchs et statistiques."
    @meta_keywords = [@team.name, @tournament.name, "équipe", "basketball", "statistiques", "matchs", "victoires", "défaites"]
    @og_title = "#{@team.name} - #{@tournament.name} | TournamentGo"
    @og_description = "Découvrez l'équipe #{@team.name} du tournoi #{@tournament.name}. Statistiques, matchs et résultats en temps réel."
    @canonical_url = team_url(@team)
    @structured_data = team_json_ld(@team, @tournament)
  end
end
