class Tournament < ApplicationRecord
  belongs_to :user

  # Associations
  has_many :pools, dependent: :destroy
  has_many :teams, through: :pools
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

  private

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, "doit être après la date de début") if end_date < start_date
  end
end
