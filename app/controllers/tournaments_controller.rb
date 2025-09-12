class TournamentsController < ApplicationController
  def index
    @tournaments = Tournament.includes(:user, :pools, :teams)
                            .where(status: ['active', 'completed'])
                            .order(created_at: :desc)

    @page_title = "Tournois de basketball"
    @meta_description = "Découvrez tous les tournois de basketball actifs et terminés sur TournamentGo. Suivez les matchs, classements et résultats de vos tournois favoris."
    @meta_keywords = ["tournois", "basketball", "actifs", "terminés", "matchs", "classements", "résultats"]
    @og_title = "Tournois de basketball - TournamentGo"
    @og_description = "Découvrez tous les tournois de basketball actifs et terminés. Suivez les matchs, classements et résultats en temps réel."
  end

  def show
    @tournament = Tournament.includes(:pools, :teams, :games, :referees).find(params[:id])
    @pools = @tournament.pools.ordered.includes(:teams)

    # Organiser les matchs par type et poule
    @pool_games = @tournament.pool_games
                            .includes(:home_team, :away_team, :winner, :referees, :pool)
                            .order(:pool_id, :game_start, :round_number)

    @knockout_games = @tournament.knockout_games
                                .includes(:home_team, :away_team, :winner, :referees)
                                .order(:game_type, :game_start, :round_number)

    # Grouper les matchs de poule par poule
    @games_by_pool = @pool_games.group_by(&:pool)

    # OPTIMISATION: Utiliser la méthode optimisée pour calculer les classements
    @pool_standings = Pool.standings_for_tournament(@tournament)

    # SEO pour la page du tournoi
    @page_title = @tournament.name
    @meta_description = "Suivez le tournoi #{@tournament.name} sur TournamentGo. Dates : #{@tournament.start_date.strftime('%d/%m/%Y')} - #{@tournament.end_date.strftime('%d/%m/%Y')}. #{@tournament.teams.count} équipes, #{@tournament.pools.count} poules. Matchs, classements et résultats en temps réel."
    @meta_keywords = [@tournament.name, "tournoi", "basketball", "matchs", "classements", "résultats", @tournament.start_date.strftime('%Y')]
    @og_title = "#{@tournament.name} - TournamentGo"
    @og_description = "Suivez le tournoi #{@tournament.name}. #{@tournament.teams.count} équipes, #{@tournament.pools.count} poules. Matchs, classements et résultats en temps réel."
    @canonical_url = tournament_url(@tournament)
    @structured_data = tournament_json_ld(@tournament)
  end
end
