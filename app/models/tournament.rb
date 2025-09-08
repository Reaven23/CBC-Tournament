class Tournament < ApplicationRecord
  belongs_to :user

  # Associations
  has_many :pools, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :pool_teams, through: :pools, source: :teams
  has_many :games, dependent: :destroy
  has_many :referees, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :status, inclusion: { in: %w[draft active completed] }
  validates :max_teams, numericality: { greater_than: 0 }
  validates :start_date, :end_date, presence: true
  validate :end_date_after_start_date

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :draft, -> { where(status: 'draft') }

  # Methods
  def pool_games
    games.where(type: 'pool')
  end

  def knockout_games
    games.where(type: %w[quarter semi final third_place])
  end

  def can_generate_quarters?
    pool_games.all?(&:played?) && games.where(type: 'quarter').empty?
  end

  def can_generate_semis?
    games.where(type: 'quarter').all?(&:played?) && games.where(type: 'semi').empty?
  end

  def can_generate_finals?
    games.where(type: 'semi').all?(&:played?) && games.where(type: 'final').empty?
  end

  def can_generate_third_place?
    has_third_place? && games.where(type: 'semi').all?(&:played?) && games.where(type: 'third_place').empty?
  end

  def generate_quarter_finals
    # Logique à implémenter
  end

  def generate_semi_finals
    # Logique à implémenter
  end

  def generate_finals
    # Logique à implémenter
  end

  def generate_third_place
    # Logique à implémenter
  end

  def create_pools_and_distribute_teams
    return false if pools.any?

    # Créer 3 poules vides
    pools.create!(name: "Poule A", position: 1)
    pools.create!(name: "Poule B", position: 2)
    pools.create!(name: "Poule C", position: 3)

    true
  end

  def generate_pool_games
    pools.each do |pool|
      teams_in_pool = pool.teams.to_a

      # Générer tous les matchs possibles dans la poule
      teams_in_pool.combination(2).each_with_index do |(team1, team2), index|
        games.create!(
          pool: pool,
          home_team: team1,
          away_team: team2,
          game_type: 'pool',
          round_number: (index / 2) + 1,
          status: 'scheduled'
        )
      end
    end
  end

  def can_generate_pool_games?
    pools.any? && pools.all? { |pool| pool.teams.count >= 2 } && games.where(game_type: 'pool').empty?
  end

  def generate_pool_games_if_ready
    if can_generate_pool_games?
      generate_pool_games
      true
    else
      false
    end
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, "doit être après la date de début") if end_date < start_date
  end
end
