class Referee < ApplicationRecord
  belongs_to :tournament

  # Game associations
  has_many :game_referees, dependent: :destroy
  has_many :games, through: :game_referees

  # Validations
  validates :first_name, :last_name, presence: true


  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def games_count
    games.count
  end
end
