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
    # Logique pour calculer le classement des équipes
    # À implémenter selon les règles de qualification
    teams.includes(:won_games).sort_by do |team|
      [-team.wins, team.losses]
    end
  end
end
