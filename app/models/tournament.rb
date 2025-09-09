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
    games.where(game_type: 'pool')
  end

  def knockout_games
    games.where(game_type: %w[quarter semi final third_place])
  end

  def can_generate_quarters?
    pool_games.all?(&:played?) && games.where(game_type: 'quarter').empty?
  end

  def can_delete_quarters?
    games.where(game_type: 'quarter').any? && games.where(game_type: %w[semi final third_place]).empty?
  end

  def can_delete_semis?
    games.where(game_type: 'semi').any? && games.where(game_type: %w[final third_place]).empty?
  end

  def can_delete_finals?
    games.where(game_type: 'final').any? && games.where(game_type: 'third_place').empty?
  end

  def delete_quarter_finals
    return false unless can_delete_quarters?

    games.where(game_type: 'quarter').destroy_all
    true
  end

  def delete_semi_finals
    return false unless can_delete_semis?

    games.where(game_type: 'semi').destroy_all
    true
  end

  def delete_finals
    return false unless can_delete_finals?

    games.where(game_type: 'final').destroy_all
    true
  end

  def can_generate_semis?
    games.where(game_type: 'quarter').any? && games.where(game_type: 'quarter').all?(&:played?) && games.where(game_type: 'semi').empty?
  end

  def can_generate_finals?
    games.where(game_type: 'semi').any? && games.where(game_type: 'semi').all?(&:played?) && games.where(game_type: 'final').empty?
  end

  def can_generate_third_place?
    has_third_place? && games.where(game_type: 'semi').any? && games.where(game_type: 'semi').all?(&:played?) && games.where(game_type: 'third_place').empty?
  end

  def generate_quarter_finals
    return false unless can_generate_quarters?

    # Récupérer les équipes qualifiées
    qualified_teams = get_qualified_teams_for_quarters

    # Créer les matchs de quarts de finale
    create_quarter_final_games(qualified_teams)

    true
  end

  def get_qualified_teams_for_quarters
    qualified_teams = []

    # Récupérer les 2 premiers de chaque poule
    pools.ordered.each do |pool|
      standings = pool.standings
      qualified_teams << standings[0] if standings[0] # 1er
      qualified_teams << standings[1] if standings[1] # 2ème
    end

    # Récupérer les 2 meilleurs troisièmes
    best_third_places = get_best_third_places
    qualified_teams.concat(best_third_places)

    qualified_teams
  end

  def get_best_third_places
    third_places = []

    # Récupérer les 3èmes de chaque poule
    pools.ordered.each do |pool|
      standings = pool.standings
      third_places << standings[2] if standings[2] # 3ème
    end

    # Trier selon les règles : victoires → goal average → points marqués
    third_places.sort do |team_a, team_b|
      # 1. Nombre de victoires
      wins_diff = team_b.wins - team_a.wins
      next wins_diff unless wins_diff == 0

      # 2. Goal average
      goal_diff = team_b.goal_difference - team_a.goal_difference
      next goal_diff unless goal_diff == 0

      # 3. Points marqués
      team_b.goals_scored - team_a.goals_scored
    end

    # Retourner les 2 meilleurs
    third_places.first(2)
  end

  def create_quarter_final_games(qualified_teams)
    # Créer les matchs de quarts de finale en évitant que deux équipes de la même poule se rencontrent
    quarter_games = []

    # Séparer les équipes par poule
    teams_by_pool = qualified_teams.group_by(&:pool)

    # Créer les matchs en respectant la contrainte de poule
    create_quarter_final_pairings(teams_by_pool, quarter_games)

    # Créer les matchs en base
    quarter_games.each_with_index do |(team1, team2), index|
      games.create!(
        home_team: team1,
        away_team: team2,
        game_type: 'quarter',
        round_number: index + 1,
        status: 'scheduled'
      )
    end
  end

  def create_quarter_final_pairings(teams_by_pool, quarter_games)
    # Récupérer les équipes par position dans leur poule
    first_places = []
    second_places = []
    third_places = []

    teams_by_pool.each do |pool, teams|
      standings = pool.standings
      teams.each do |team|
        position = standings.index(team)
        case position
        when 0
          first_places << team
        when 1
          second_places << team
        when 2
          third_places << team
        end
      end
    end

    # Trier les premiers selon les règles : victoires → goal average → points marqués
    best_first_places = first_places.sort do |team_a, team_b|
      # 1. Nombre de victoires
      wins_diff = team_b.wins - team_a.wins
      next wins_diff unless wins_diff == 0

      # 2. Goal average
      goal_diff = team_b.goal_difference - team_a.goal_difference
      next goal_diff unless goal_diff == 0

      # 3. Points marqués
      team_b.goals_scored - team_a.goals_scored
    end

    # Trier les deuxièmes selon les mêmes règles
    best_second_places = second_places.sort do |team_a, team_b|
      # 1. Nombre de victoires
      wins_diff = team_b.wins - team_a.wins
      next wins_diff unless wins_diff == 0

      # 2. Goal average
      goal_diff = team_b.goal_difference - team_a.goal_difference
      next goal_diff unless goal_diff == 0

      # 3. Points marqués
      team_b.goals_scored - team_a.goals_scored
    end

    # Créer les 4 matchs selon la nouvelle logique :
    # - 2 meilleurs premiers vs 2 meilleurs troisièmes (pas de leur poule)
    # - 3ème premier vs meilleur deuxième
    # - 2 autres deuxièmes s'affrontent

    if best_first_places.length >= 3 && best_second_places.length >= 3 && third_places.length >= 2
      # Match 1: Meilleur 1er vs Meilleur 3ème (pas de sa poule)
      quarter_games << [best_first_places[0], find_third_from_different_pool(best_first_places[0], third_places)]

      # Match 2: 2ème meilleur 1er vs 2ème meilleur 3ème (pas de sa poule)
      quarter_games << [best_first_places[1], find_third_from_different_pool(best_first_places[1], third_places)]

      # Match 3: 3ème meilleur 1er vs Meilleur 2ème
      quarter_games << [best_first_places[2], best_second_places[0]]

      # Match 4: 2ème meilleur 2ème vs 3ème meilleur 2ème
      quarter_games << [best_second_places[1], best_second_places[2]]
    end
  end

  def find_third_from_different_pool(first_place_team, third_places)
    # Trouver un 3ème qui n'est pas de la même poule que le 1er
    third_places.find { |third| third.pool != first_place_team.pool } || third_places.first
  end

  def generate_semi_finals
    return false unless can_generate_semis?

    # Récupérer les 4 équipes qualifiées des quarts de finale
    quarter_games = games.where(game_type: 'quarter')
    qualified_teams = quarter_games.map(&:winner).compact

    return false if qualified_teams.length != 4

    # Créer les 2 matchs de demi-finale
    semi_games = []

    # Semi-finale 1: Vainqueur Quart 1 vs Vainqueur Quart 2
    semi_games << [qualified_teams[0], qualified_teams[1]]

    # Semi-finale 2: Vainqueur Quart 3 vs Vainqueur Quart 4
    semi_games << [qualified_teams[2], qualified_teams[3]]

    # Créer les matchs en base
    semi_games.each_with_index do |(home_team, away_team), index|
      games.create!(
        home_team: home_team,
        away_team: away_team,
        game_type: 'semi',
        round_number: index + 1,
        status: 'scheduled'
      )
    end

    true
  end

  def generate_finals
    return false unless can_generate_finals?

    # Récupérer les 2 équipes qualifiées des demi-finales
    semi_games = games.where(game_type: 'semi')
    qualified_teams = semi_games.map(&:winner).compact

    return false if qualified_teams.length != 2

    # Créer le match de finale
    games.create!(
      home_team: qualified_teams[0],
      away_team: qualified_teams[1],
      game_type: 'final',
      round_number: 1,
      status: 'scheduled'
    )

    true
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
