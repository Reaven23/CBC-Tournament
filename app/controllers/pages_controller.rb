class PagesController < ApplicationController
  def home
    @page_title = "Accueil"
    @meta_description = "Découvrez TournamentGo, la plateforme moderne de gestion de tournois de basketball. Suivez les matchs, classements et résultats en temps réel. Organisez votre propre tournoi facilement."
    @meta_keywords = ["accueil", "basketball", "tournoi", "gestion", "sport", "match", "classement"]
    @og_title = "TournamentGo - Plateforme de gestion de tournois de basketball"
    @og_description = "Découvrez TournamentGo, la plateforme moderne de gestion de tournois de basketball. Suivez les matchs, classements et résultats en temps réel."
    @structured_data = website_json_ld
  end
end
