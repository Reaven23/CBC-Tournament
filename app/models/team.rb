class Team < ApplicationRecord
  belongs_to :pool

  # Active Storage for team photo
  has_one_attached :photo

  # Game associations
  has_many :home_games, class_name: 'Game', foreign_key: 'home_team_id', dependent: :destroy
  has_many :away_games, class_name: 'Game', foreign_key: 'away_team_id', dependent: :destroy
  has_many :won_games, class_name: 'Game', foreign_key: 'winner_id', dependent: :nullify

  # Validations
  validates :name, presence: true, uniqueness: { scope: :pool_id }
  validates :color, presence: true

  # Methods
  def games
    Game.where("home_team_id = ? OR away_team_id = ?", id, id)
  end

  def total_games
    games.count
  end

  def wins
    won_games.count
  end

  def losses
    total_games - wins
  end
end
