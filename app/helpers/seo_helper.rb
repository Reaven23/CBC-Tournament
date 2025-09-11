module SeoHelper
  def page_title(page_title = nil)
    base_title = "TournamentGo - Gestion de tournois de basketball"

    if page_title.present?
      "#{page_title} | #{base_title}"
    else
      base_title
    end
  end

  def meta_description(description = nil)
    description || "TournamentGo - Plateforme moderne de gestion de tournois de basketball. Suivez les matchs, classements et résultats en temps réel."
  end

  def meta_keywords(keywords = [])
    base_keywords = ["basketball", "tournoi", "sport", "match", "classement", "TournamentGo"]
    keywords = [] if keywords.nil?
    (base_keywords + keywords).join(", ")
  end

  def og_title(title = nil)
    title || "TournamentGo - Gestion de tournois de basketball"
  end

  def og_description(description = nil)
    description || "Plateforme moderne de gestion de tournois de basketball. Suivez les matchs, classements et résultats en temps réel."
  end

  def og_image(image_url = nil)
    image_url || asset_url("logo.png")
  end

  def twitter_card_type
    "summary_large_image"
  end

  def canonical_url(url = nil)
    url || request.url
  end
end
