class RefereesController < ApplicationController
  def index
    @tournament = Tournament.includes(:referees, :games).find(params[:tournament_id])
    @referees = @tournament.referees.includes(:games).order(:first_name, :last_name)

    # SEO pour la page des arbitres
    @page_title = "Arbitres - #{@tournament.name}"
    @meta_description = "Découvrez tous les arbitres du tournoi #{@tournament.name}. Planning des matchs, terrains et horaires pour chaque arbitre."
    @meta_keywords = [@tournament.name, "arbitres", "planning", "matchs", "terrains", "basketball"]
    @og_title = "Arbitres - #{@tournament.name} | TournamentGo"
    @og_description = "Planning des arbitres pour le tournoi #{@tournament.name}. Découvrez les matchs et terrains assignés à chaque arbitre."
    @canonical_url = tournament_referees_url(@tournament)
    @structured_data = referees_json_ld(@tournament)
  end

  def show
    @tournament = Tournament.includes(:referees, :games).find(params[:tournament_id])
    @referee = @tournament.referees.includes(:games).find(params[:id])

    # Récupérer tous les matchs de l'arbitre triés par heure
    @games = @referee.games
                     .includes(:home_team, :away_team, :winner, :pool)
                     .order(:game_start, :round_number)

    # Séparer les matchs par type
    @pool_games = @games.where(game_type: 'pool')
    @knockout_games = @games.where(game_type: %w[quarter semi final third_place])

    # Statistiques de l'arbitre
    @stats = {
      total_games: @games.count,
      pool_games: @pool_games.count,
      knockout_games: @knockout_games.count,
      completed_games: @games.where(status: 'played').count,
      upcoming_games: @games.where(status: 'scheduled').count
    }

    # SEO pour la page de l'arbitre
    @page_title = "#{@referee.name} - Arbitre #{@tournament.name}"
    @meta_description = "Planning de l'arbitre #{@referee.name} pour le tournoi #{@tournament.name}. #{@stats[:total_games]} matchs assignés, #{@stats[:completed_games]} terminés."
    @meta_keywords = [@referee.name, @tournament.name, "arbitre", "planning", "matchs", "terrains", "basketball"]
    @og_title = "#{@referee.name} - Arbitre #{@tournament.name} | TournamentGo"
    @og_description = "Planning complet de l'arbitre #{@referee.name} pour le tournoi #{@tournament.name}."
    @canonical_url = tournament_referee_url(@tournament, @referee)
    @structured_data = referee_json_ld(@referee, @tournament)
  end

  private

  def referees_json_ld(tournament)
    {
      "@context": "https://schema.org",
      "@type": "SportsEvent",
      "name": "#{tournament.name} - Arbitres",
      "description": "Liste des arbitres du tournoi #{tournament.name}",
      "sport": "Basketball",
      "organizer": {
        "@type": "Organization",
        "name": "TournamentGo",
        "url": root_url
      },
      "url": tournament_referees_url(tournament)
    }.to_json.html_safe
  end

  def referee_json_ld(referee, tournament)
    {
      "@context": "https://schema.org",
      "@type": "Person",
      "name": referee.name,
      "jobTitle": "Arbitre de basketball",
      "memberOf": {
        "@type": "SportsEvent",
        "name": tournament.name,
        "url": tournament_url(tournament)
      },
      "url": tournament_referee_url(tournament, referee)
    }.to_json.html_safe
  end
end
