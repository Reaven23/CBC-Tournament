module StructuredDataHelper
  def tournament_json_ld(tournament)
    {
      "@context": "https://schema.org",
      "@type": "SportsEvent",
      "name": tournament.name,
      "description": "Tournoi de basketball #{tournament.name}",
      "startDate": tournament.start_date.iso8601,
      "endDate": tournament.end_date.iso8601,
      "eventStatus": tournament.status == 'active' ? "https://schema.org/EventScheduled" : "https://schema.org/EventPostponed",
      "location": {
        "@type": "Place",
        "name": "TournamentGo"
      },
      "organizer": {
        "@type": "Organization",
        "name": "TournamentGo",
        "url": root_url
      },
      "sport": "Basketball",
      "numberOfParticipants": tournament.teams.count,
      "url": tournament_url(tournament)
    }.to_json.html_safe
  end

  def team_json_ld(team, tournament)
    {
      "@context": "https://schema.org",
      "@type": "SportsTeam",
      "name": team.name,
      "sport": "Basketball",
      "memberOf": {
        "@type": "SportsEvent",
        "name": tournament.name,
        "url": tournament_url(tournament)
      },
      "url": tournament_team_url(tournament, team)
    }.to_json.html_safe
  end

  def website_json_ld
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "name": "TournamentGo",
      "description": "Plateforme moderne de gestion de tournois de basketball",
      "url": root_url,
      "potentialAction": {
        "@type": "SearchAction",
        "target": "#{tournaments_url}?search={search_term_string}",
        "query-input": "required name=search_term_string"
      }
    }.to_json.html_safe
  end
end
