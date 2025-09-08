class GameReferee < ApplicationRecord
  belongs_to :game
  belongs_to :referee

  # Validations
  validates :role, inclusion: { in: %w[referee assistant table_official] }
  validates :referee_id, uniqueness: { scope: [:game_id, :role] }

  # Scopes
  scope :referees, -> { where(role: 'referee') }
  scope :assistants, -> { where(role: 'assistant') }
  scope :table_officials, -> { where(role: 'table_official') }
end
