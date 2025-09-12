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

  def wins_pool
    won_games.where(status: 'played', game_type: 'pool').count
  end

  def losses
    # Seuls les matchs de poule comptent pour les défaites
    pool_losses
  end

  def losses_pool
    games.where(status: 'played', game_type: 'pool').count - wins_pool
  end

  def points
    # 2 points pour une victoire, 1 point pour une défaite
    # Seuls les matchs de poule comptent pour les points
    (pool_wins * 2) + (pool_losses * 1)
  end

  def win_loss_record
    "#{wins_pool} - #{losses_pool}"
  end

  # Méthodes pour les matchs de poule uniquement
  def pool_games
    games.where(game_type: 'pool')
  end

  def pool_played_games
    pool_games.where(status: 'played')
  end

  # MÉTHODES OPTIMISÉES - Calculent toutes les stats en une seule requête
  def pool_stats
    @pool_stats ||= calculate_pool_stats
  end

  def pool_wins
    pool_stats[:wins]
  end

  def pool_losses
    pool_stats[:losses]
  end

  def pool_points
    pool_stats[:points]
  end

  def pool_goals_scored
    pool_stats[:goals_scored]
  end

  def pool_goals_conceded
    pool_stats[:goals_conceded]
  end

  def pool_goal_difference
    pool_stats[:goal_difference]
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

  private

  def calculate_pool_stats
    # Une seule requête pour récupérer tous les matchs de poule joués
    games_data = pool_played_games.pluck(:home_team_id, :away_team_id, :home_score, :away_score, :winner_id)
    
    wins = 0
    goals_scored = 0
    goals_conceded = 0

    games_data.each do |home_team_id, away_team_id, home_score, away_score, winner_id|
      if home_team_id == id
        # L'équipe était à domicile
        goals_scored += home_score || 0
        goals_conceded += away_score || 0
        wins += 1 if winner_id == id
      else
        # L'équipe était à l'extérieur
        goals_scored += away_score || 0
        goals_conceded += home_score || 0
        wins += 1 if winner_id == id
      end
    end

    losses = games_data.length - wins
    points = (wins * 2) + (losses * 1)
    goal_difference = goals_scored - goals_conceded

    {
      wins: wins,
      losses: losses,
      points: points,
      goals_scored: goals_scored,
      goals_conceded: goals_conceded,
      goal_difference: goal_difference
    }
  end
end
