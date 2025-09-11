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
    (base_keywords + keywords).join(", ")
  end

  def og_title(title = nil)
    title || "TournamentGo - Gestion de tournois de basketball"
  end

  def og_description(description = nil)
    description || "Plateforme moderne de gestion de tournois de basketball. Suivez les matchs, classements et résultats en temps réel."
  end

  def og_image(image_url = nil)
    if image_url.present?
      image_url
    else
      # Utiliser Cloudinary pour optimiser l'image Open Graph
      if Rails.env.production?
        "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/w_1200,h_630,c_fill,q_auto,f_auto/logo.png"
      else
        asset_url("logo.png")
      end
    end
  end

  def twitter_card_type
    "summary_large_image"
  end

  def canonical_url(url = nil)
    url || request.url
  end
end
