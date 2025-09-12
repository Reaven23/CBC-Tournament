# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Début du seeding..."

# Nettoyer les données existantes



# Créer un utilisateur admin
puts "👤 Création de l'utilisateur admin..."
admin = User.create!(
  email: "admin@tournamentgo.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Admin",
  last_name: "TournamentGo",
  role: "super_admin"
)

# Villes françaises pour les équipes
cities = [
  "Paris", "Lyon", "Marseille", "Toulouse", "Nice", "Nantes", "Strasbourg", "Montpellier",
  "Bordeaux", "Lille", "Rennes", "Reims", "Le Havre", "Saint-Étienne", "Toulon", "Grenoble",
  "Dijon", "Angers", "Nîmes", "Villeurbanne", "Saint-Denis", "Le Mans", "Aix-en-Provence",
  "Clermont-Ferrand", "Brest", "Tours", "Limoges", "Amiens", "Annecy", "Perpignan"
]

# Couleurs pour les équipes
colors = [
  "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7", "#DDA0DD", "#98D8C8", "#F7DC6F",
  "#BB8FCE", "#85C1E9", "#F8C471", "#82E0AA", "#F1948A", "#85C1E9", "#D7BDE2", "#A9DFBF"
]

# Créer un tournoi
puts "🏆 Création du tournoi..."
tournament = Tournament.create!(
  name: "Championnat de France de Basketball 2024",
  description: "Tournoi national de basketball avec 12 équipes réparties en 3 poules de 4 équipes chacune.",
  start_date: Date.current,
  end_date: Date.current + 3.days,
  status: "active",
  max_teams: 12,
  user: admin
)

# Créer 3 poules
puts "📋 Création des poules..."
pools = []
3.times do |i|
  pool = Pool.create!(
    name: "Poule #{('A'..'C').to_a[i]}",
    position: i + 1,
    tournament: tournament
  )
  pools << pool
end

# Créer 12 équipes (4 par poule)
puts "🏀 Création des équipes..."
teams = []
pools.each_with_index do |pool, pool_index|
  4.times do |team_index|
    city = cities.sample
    cities.delete(city) # Éviter les doublons

    team = Team.create!(
      name: "#{city} Basket",
      color: colors.sample,
      description: "Équipe de basketball de #{city}",
      pool: pool,
      tournament: tournament
    )
    teams << team
  end
end

# Créer 2 arbitres
puts "👨‍⚖️ Création des arbitres..."
referees = []
2.times do |i|
  referee = Referee.create!(
    first_name: ["Jean", "Pierre", "Michel", "Philippe", "Alain", "Bernard"].sample,
    last_name: ["Martin", "Durand", "Dubois", "Moreau", "Laurent", "Simon"].sample,
    email: "arbitre#{i+1}@tournamentgo.com",
    phone: "06#{rand(10000000..99999999)}",
    tournament: tournament
  )
  referees << referee
end

# Générer tous les matchs de poules
puts "⚽ Génération des matchs de poules..."
pools.each do |pool|
  pool_teams = pool.teams.to_a

  # Générer tous les matchs possibles dans la poule (chaque équipe joue contre chaque autre)
  pool_teams.combination(2).each_with_index do |(team1, team2), index|
    # Déterminer l'équipe à domicile et à l'extérieur
    home_team = [team1, team2].sample
    away_team = (home_team == team1) ? team2 : team1

    # Générer des scores aléatoires (entre 40 et 120 points)
    home_score = rand(40..120)
    away_score = rand(40..120)

    # Déterminer le gagnant
    winner = home_score > away_score ? home_team : away_team

    # Créer le match
    game = Game.create!(
      tournament: tournament,
      pool: pool,
      home_team: home_team,
      away_team: away_team,
      home_score: home_score,
      away_score: away_score,
      winner: winner,
      game_type: "pool",
      status: "played",
      round_number: (index / 2) + 1,
      game_start: tournament.start_date + rand(0..2).days + rand(9..18).hours,
      court_number: rand(1..3)
    )

    # Assigner les arbitres au match
    GameReferee.create!(game: game, referee: referees.sample, role: 'referee')
    GameReferee.create!(game: game, referee: referees.sample, role: 'assistant') if rand < 0.3 # 30% de chance d'avoir 2 arbitres
  end
end

# Afficher les statistiques
puts "\n📊 Statistiques du tournoi créé :"
puts "   🏆 Tournoi: #{tournament.name}"
puts "   📅 Dates: #{tournament.start_date} - #{tournament.end_date}"
puts "   🏀 Équipes: #{teams.count}"
puts "   📋 Poules: #{pools.count}"
puts "   👨‍⚖️ Arbitres: #{referees.count}"
puts "   ⚽ Matchs joués: #{tournament.games.count}"
puts "   🎯 Matchs par poule: #{tournament.games.group(:pool_id).count}"

# Afficher les classements par poule
puts "\n🏆 Classements par poule :"
pools.each do |pool|
  puts "\n   #{pool.name}:"
  standings = pool.standings
  standings.each_with_index do |team, index|
    puts "     #{index + 1}. #{team.name} - #{team.points}pts (#{team.wins}V-#{team.losses}D) - Diff: #{team.goal_difference}"
  end
end

puts "\n✅ Seeding terminé avec succès !"
puts "🔗 Vous pouvez maintenant visiter le tournoi à l'ID: #{tournament.id}"
