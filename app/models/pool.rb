class Pool < ApplicationRecord
  belongs_to :tournament

  # Associations
  has_many :teams, dependent: :destroy
  has_many :games, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :name, uniqueness: { scope: :tournament_id }
  validates :position, uniqueness: { scope: :tournament_id }

  # Scopes
  scope :ordered, -> { order(:position) }

  # Methods
  def teams_count
    teams.count
  end

  def games_count
    games.count
  end

  def completed_games_count
    games.where(status: 'played').count
  end

  def all_games_played?
    games.all?(&:played?)
  end

  def standings
    # Règles de classement basées uniquement sur les matchs de poule :
    # 1. Nombre de points (2 pour victoire, 1 pour défaite)
    # 2. En cas d'égalité : confrontation directe (si applicable)
    # 3. Si 3+ équipes à égalité : goal average (différence de buts)
    # 4. Si goal average identique : équipe qui a marqué le plus de points (meilleure attaque)
    # Note: Si goal average ET attaque sont égaux, la défense sera forcément égale aussi

    # OPTIMISATION: Précharger toutes les données nécessaires
    teams_with_stats = teams.includes(:won_games).map do |team|
      # Forcer le calcul des stats pour cette équipe (utilise le cache)
      team.pool_stats
      team
    end

    teams_with_stats.sort do |team_a, team_b|
      # 1. Comparaison par points (déjà basés sur les matchs de poule)
      points_diff = team_b.points - team_a.points
      next points_diff unless points_diff == 0

      # 2. En cas d'égalité de points : confrontation directe (seulement si 2 équipes)
      # Pour 3+ équipes, on passe directement au goal average
      if teams.count { |t| t.points == team_a.points } == 2
        if team_a.head_to_head_victory?(team_b)
          -1  # team_a gagne
        elsif team_b.head_to_head_victory?(team_a)
          1   # team_b gagne
        end
      end

      # 3. Si pas de confrontation directe applicable ou égalité : goal average
      goal_diff = team_b.goal_difference - team_a.goal_difference
      next goal_diff unless goal_diff == 0

      # 4. Si goal average identique : équipe qui a marqué le plus de points (meilleure attaque)
      goals_scored_diff = team_b.goals_scored - team_a.goals_scored
      next goals_scored_diff unless goals_scored_diff == 0

      # 5. Si tout est égal (points, goal average, attaque), alors défense est forcément égale
      # Dans ce cas, on garde l'ordre alphabétique ou l'ordre d'insertion
      0  # Égalité parfaite
    end
  end

  # Méthode de classe optimisée pour calculer les classements de toutes les poules d'un tournoi
  def self.standings_for_tournament(tournament)
    pools = tournament.pools.ordered.includes(teams: [:won_games])

    standings = {}
    pools.each do |pool|
      standings[pool] = pool.standings
    end

    standings
  end
end
