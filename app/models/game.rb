class Game < ApplicationRecord
  belongs_to :tournament
  belongs_to :pool, optional: true
  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'
  belongs_to :winner, class_name: 'Team', optional: true

  # Referee associations
  has_many :game_referees, dependent: :destroy
  has_many :referees, through: :game_referees

  # Validations
  validates :game_type, inclusion: { in: %w[pool quarter semi final third_place] }
  validates :status, inclusion: { in: %w[scheduled played] }
  validates :home_score, :away_score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :round_number, presence: true, numericality: { greater_than: 0 }
  validates :court_number, presence: true, if: :game_start?

  # Callbacks
  after_update :calculate_winner, if: -> { saved_change_to_home_score? || saved_change_to_away_score? }

  # Scopes
  scope :by_type, ->(game_type) { where(game_type: game_type) }
  scope :by_status, ->(game_status) { where(status: game_status) }
  scope :pool_games, -> { where(game_type: 'pool') }
  scope :knockout_games, -> { where(game_type: %w[quarter semi final third_place]) }

  # Methods
  def played?
    status == 'played'
  end

  def scheduled?
    status == 'scheduled'
  end

  def pool_game?
    game_type == 'pool'
  end

  def knockout_game?
    %w[quarter semi final third_place].include?(game_type)
  end

  def formatted_game_start
    return "Non programmé" unless game_start?
    game_start.strftime("%Hh%M")
  end

  def game_datetime
    return nil unless game_start? && tournament.start_date?
    # Combine la date du tournoi avec l'heure du match
    tournament.start_date.to_datetime + game_start.hour.hours + game_start.min.minutes
  end

  def can_generate_next_phase?
    case game_type
    when 'pool'
      tournament.pool_games.all?(&:played?)
    when 'quarter'
      tournament.games.by_type('quarter').all?(&:played?)
    when 'semi'
      tournament.games.by_type('semi').all?(&:played?)
    else
      false
    end
  end

  private

  def calculate_winner
    return unless home_score.present? && away_score.present?

    Rails.logger.info "Calculating winner for game #{id}: #{home_team.name} #{home_score} - #{away_score} #{away_team.name}"

    if home_score > away_score
      update_column(:winner_id, home_team_id)
      Rails.logger.info "Winner: #{home_team.name}"
    elsif away_score > home_score
      update_column(:winner_id, away_team_id)
      Rails.logger.info "Winner: #{away_team.name}"
    else
      # Match nul - pas de winner pour l'instant
      update_column(:winner_id, nil)
      Rails.logger.info "Match nul - pas de winner"
    end

    # Marquer le match comme joué
    update_column(:status, 'played')
    Rails.logger.info "Game #{id} marked as played"
  end
end
