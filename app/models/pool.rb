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
    # Règles de classement :
    # 1. Nombre de points (2 pour victoire, 1 pour défaite)
    # 2. En cas d'égalité : confrontation directe
    # 3. Si 3+ équipes à égalité : goal average (différence de buts)

    teams.includes(:won_games).sort do |team_a, team_b|
      # 1. Comparaison par points
      points_diff = team_b.points - team_a.points
      next points_diff unless points_diff == 0

      # 2. En cas d'égalité de points : confrontation directe
      if team_a.head_to_head_victory?(team_b)
        -1  # team_a gagne
      elsif team_b.head_to_head_victory?(team_a)
        1   # team_b gagne
      else
        # 3. Si pas de confrontation directe ou égalité : goal average
        team_b.goal_difference - team_a.goal_difference
      end
    end
  end
end
