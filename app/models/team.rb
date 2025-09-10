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
    # Seuls les matchs de poule comptent pour les victoires
    pool_wins
  end

  def losses
    # Seuls les matchs de poule comptent pour les défaites
    pool_losses
  end

  def points
    # 2 points pour une victoire, 1 point pour une défaite
    # Seuls les matchs de poule comptent pour les points
    (pool_wins * 2) + (pool_losses * 1)
  end

  def win_loss_record
    "#{wins} - #{losses}"
  end

  # Méthodes pour les matchs de poule uniquement
  def pool_games
    games.where(game_type: 'pool')
  end

  def pool_played_games
    pool_games.where(status: 'played')
  end

  def pool_wins
    pool_played_games.count { |game| game.winner_id == id }
  end

  def pool_losses
    pool_played_games.count - pool_wins
  end

  def pool_points
    # 2 points pour une victoire, 1 point pour une défaite
    (pool_wins * 2) + (pool_losses * 1)
  end

  def pool_goals_scored
    pool_played_games.sum do |game|
      if game.home_team_id == id
        game.home_score || 0
      else
        game.away_score || 0
      end
    end
  end

  def pool_goals_conceded
    pool_played_games.sum do |game|
      if game.home_team_id == id
        game.away_score || 0
      else
        game.home_score || 0
      end
    end
  end

  def pool_goal_difference
    pool_goals_scored - pool_goals_conceded
  end

  # Méthodes pour le classement (matchs de poule uniquement)
  def goals_scored
    # Seuls les matchs de poule comptent pour les buts marqués
    pool_goals_scored
  end

  def goals_conceded
    # Seuls les matchs de poule comptent pour les buts encaissés
    pool_goals_conceded
  end

  def goal_difference
    # Seuls les matchs de poule comptent pour la différence de buts
    pool_goal_difference
  end

  # Méthode pour vérifier la confrontation directe (matchs de poule uniquement)
  def head_to_head_victory?(other_team)
    direct_games = pool_played_games.where(
      "(home_team_id = ? AND away_team_id = ?) OR (home_team_id = ? AND away_team_id = ?)",
      id, other_team.id, other_team.id, id
    )

    return false if direct_games.empty?

    victories = direct_games.count { |game| game.winner_id == id }
    defeats = direct_games.count { |game| game.winner_id == other_team.id }

    victories > defeats
  end
end
