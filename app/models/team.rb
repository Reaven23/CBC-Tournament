class Team < ApplicationRecord
  belongs_to :pool, optional: true
  belongs_to :tournament

  # Active Storage for team photo
  has_one_attached :photo

  # Game associations
  has_many :home_games, class_name: 'Game', foreign_key: 'home_team_id', dependent: :destroy
  has_many :away_games, class_name: 'Game', foreign_key: 'away_team_id', dependent: :destroy
  has_many :won_games, class_name: 'Game', foreign_key: 'winner_id', dependent: :nullify

  # Validations
  validates :name, presence: true, uniqueness: { scope: :tournament_id }
  validates :color, presence: true

  # Methods
  def games
    Game.where("home_team_id = ? OR away_team_id = ?", id, id)
  end

  def played_games
    games.where(status: 'played')
  end

  def total_games
    played_games.count
  end

  def wins
    won_games.where(status: 'played').count
  end

  def wins_pool
    won_games.where(status: 'played', game_type: 'pool').count
  end

  def losses
    total_games - wins
  end

  def losses_pool
    games.where(status: 'played', game_type: 'pool').count - wins_pool
  end

  def points
    # 2 points pour une victoire, 1 point pour une défaite
    (wins * 2) + (losses * 1)
  end

  def win_loss_record
    "#{wins_pool} - #{losses_pool}"
  end

  # Méthodes pour le classement
  def goals_scored
    played_games.sum do |game|
      if game.home_team_id == id
        game.home_score || 0
      else
        game.away_score || 0
      end
    end
  end

  def goals_conceded
    played_games.sum do |game|
      if game.home_team_id == id
        game.away_score || 0
      else
        game.home_score || 0
      end
    end
  end

  def goal_difference
    goals_scored - goals_conceded
  end

  # Méthode pour vérifier la confrontation directe
  def head_to_head_victory?(other_team)
    direct_games = played_games.where(
      "(home_team_id = ? AND away_team_id = ?) OR (home_team_id = ? AND away_team_id = ?)",
      id, other_team.id, other_team.id, id
    )

    return false if direct_games.empty?

    victories = direct_games.count { |game| game.winner_id == id }
    defeats = direct_games.count { |game| game.winner_id == other_team.id }

    victories > defeats
  end
end
