# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Début du seeding..."

# Nettoyer les données existantes
if Tournament.last
  Tournament.last.destroy
end

if User.last
  User.last.destroy
end


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

# Générer des matchs de poules avec des scénarios de test spécifiques
puts "⚽ Génération des matchs de poules avec scénarios de test..."

pools.each_with_index do |pool, pool_index|
  pool_teams = pool.teams.to_a
  puts "   📋 #{pool.name}: #{pool_teams.map(&:name).join(', ')}"

  case pool_index
  when 0
    # POULE A : Test confrontation directe (2 équipes à égalité 2-1 et 1-2)
    puts "     🎯 Scénario: 2 équipes à égalité (confrontation directe)"
    # Équipe 1: 2 victoires, 1 défaite
    # Équipe 2: 2 victoires, 1 défaite (mais perd contre équipe 1)
    # Équipe 3: 1 victoire, 2 défaites
    # Équipe 4: 1 victoire, 2 défaites

    # Match 1: Équipe 1 bat Équipe 2 (confrontation directe - Équipe 1 doit être devant)
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[0], away_team: pool_teams[1],
      home_score: 85, away_score: 75, winner: pool_teams[0],
      game_type: "pool", status: "played", round_number: 1,
      game_start: tournament.start_date + 9.hours, court_number: 1
    )

    # Match 2: Équipe 1 bat Équipe 3
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[0], away_team: pool_teams[2],
      home_score: 90, away_score: 80, winner: pool_teams[0],
      game_type: "pool", status: "played", round_number: 1,
      game_start: tournament.start_date + 11.hours, court_number: 1
    )

    # Match 3: Équipe 2 bat Équipe 3
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[1], away_team: pool_teams[2],
      home_score: 88, away_score: 82, winner: pool_teams[1],
      game_type: "pool", status: "played", round_number: 1,
      game_start: tournament.start_date + 13.hours, court_number: 1
    )

    # Match 4: Équipe 2 bat Équipe 4
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[1], away_team: pool_teams[3],
      home_score: 92, away_score: 78, winner: pool_teams[1],
      game_type: "pool", status: "played", round_number: 2,
      game_start: tournament.start_date + 1.day + 9.hours, court_number: 1
    )

    # Match 5: Équipe 3 bat Équipe 4
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[2], away_team: pool_teams[3],
      home_score: 86, away_score: 84, winner: pool_teams[2],
      game_type: "pool", status: "played", round_number: 2,
      game_start: tournament.start_date + 1.day + 11.hours, court_number: 1
    )

    # Match 6: Équipe 1 perd contre Équipe 4 (pour équilibrer)
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[0], away_team: pool_teams[3],
      home_score: 75, away_score: 85, winner: pool_teams[3],
      game_type: "pool", status: "played", round_number: 2,
      game_start: tournament.start_date + 1.day + 13.hours, court_number: 1
    )

  when 1
    # POULE B : Test classement normal (3v, 2v, 1v, 0v)
    puts "     🎯 Scénario: Classement normal (3v, 2v, 1v, 0v)"
    # Équipe 1: 3 victoires (1ère)
    # Équipe 2: 2 victoires (2ème)
    # Équipe 3: 1 victoire (3ème)
    # Équipe 4: 0 victoire (4ème)

    # Match 1: Équipe 1 bat Équipe 2
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[0], away_team: pool_teams[1],
      home_score: 95, away_score: 85, winner: pool_teams[0],
      game_type: "pool", status: "played", round_number: 1,
      game_start: tournament.start_date + 9.hours, court_number: 2
    )

    # Match 2: Équipe 1 bat Équipe 3
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[0], away_team: pool_teams[2],
      home_score: 90, away_score: 80, winner: pool_teams[0],
      game_type: "pool", status: "played", round_number: 1,
      game_start: tournament.start_date + 11.hours, court_number: 2
    )

    # Match 3: Équipe 1 bat Équipe 4
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[0], away_team: pool_teams[3],
      home_score: 100, away_score: 70, winner: pool_teams[0],
      game_type: "pool", status: "played", round_number: 1,
      game_start: tournament.start_date + 13.hours, court_number: 2
    )

    # Match 4: Équipe 2 bat Équipe 3
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[1], away_team: pool_teams[2],
      home_score: 88, away_score: 82, winner: pool_teams[1],
      game_type: "pool", status: "played", round_number: 2,
      game_start: tournament.start_date + 1.day + 9.hours, court_number: 2
    )

    # Match 5: Équipe 2 bat Équipe 4
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[1], away_team: pool_teams[3],
      home_score: 92, away_score: 78, winner: pool_teams[1],
      game_type: "pool", status: "played", round_number: 2,
      game_start: tournament.start_date + 1.day + 11.hours, court_number: 2
    )

    # Match 6: Équipe 3 bat Équipe 4
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[2], away_team: pool_teams[3],
      home_score: 86, away_score: 84, winner: pool_teams[2],
      game_type: "pool", status: "played", round_number: 2,
      game_start: tournament.start_date + 1.day + 13.hours, court_number: 2
    )

  when 2
    # POULE C : Test goal average (1 équipe à 3v, 3 équipes à 1v)
    puts "     🎯 Scénario: Goal average (3v, 1v, 1v, 1v)"
    # Équipe 1: 3 victoires (1ère)
    # Équipe 2: 1 victoire (2ème par goal average)
    # Équipe 3: 1 victoire (3ème par goal average)
    # Équipe 4: 1 victoire (4ème par goal average)

    # Match 1: Équipe 1 bat Équipe 2 (gros écart)
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[0], away_team: pool_teams[1],
      home_score: 100, away_score: 70, winner: pool_teams[0],
      game_type: "pool", status: "played", round_number: 1,
      game_start: tournament.start_date + 9.hours, court_number: 3
    )

    # Match 2: Équipe 1 bat Équipe 3 (moyen écart)
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[0], away_team: pool_teams[2],
      home_score: 90, away_score: 75, winner: pool_teams[0],
      game_type: "pool", status: "played", round_number: 1,
      game_start: tournament.start_date + 11.hours, court_number: 3
    )

    # Match 3: Équipe 1 bat Équipe 4 (petit écart)
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[0], away_team: pool_teams[3],
      home_score: 85, away_score: 80, winner: pool_teams[0],
      game_type: "pool", status: "played", round_number: 1,
      game_start: tournament.start_date + 13.hours, court_number: 3
    )

    # Match 4: Équipe 2 bat Équipe 3 (gros écart - Équipe 2 meilleur goal average)
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[1], away_team: pool_teams[2],
      home_score: 95, away_score: 75, winner: pool_teams[1],
      game_type: "pool", status: "played", round_number: 2,
      game_start: tournament.start_date + 1.day + 9.hours, court_number: 3
    )

    # Match 5: Équipe 3 bat Équipe 4 (moyen écart - Équipe 3 2ème meilleur goal average)
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[2], away_team: pool_teams[3],
      home_score: 90, away_score: 80, winner: pool_teams[2],
      game_type: "pool", status: "played", round_number: 2,
      game_start: tournament.start_date + 1.day + 11.hours, court_number: 3
    )

    # Match 6: Équipe 4 bat Équipe 2 (petit écart - Équipe 4 3ème goal average)
    Game.create!(
      tournament: tournament, pool: pool,
      home_team: pool_teams[3], away_team: pool_teams[1],
      home_score: 89, away_score: 85, winner: pool_teams[3],
      game_type: "pool", status: "played", round_number: 2,
      game_start: tournament.start_date + 1.day + 13.hours, court_number: 3
    )
  end

  # Assigner les arbitres à tous les matchs de la poule
  pool.games.each do |game|
    GameReferee.create!(game: game, referee: referees.sample, role: 'referee')
    GameReferee.create!(game: game, referee: referees.sample, role: 'assistant') if rand < 0.3
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
    # Forcer le calcul des stats pour cette équipe
    team.pool_stats
    puts "     #{index + 1}. #{team.name} - #{team.points}pts (#{team.wins}V-#{team.losses}D) - Diff: #{team.goal_difference}"
  end
end

puts "\n✅ Seeding terminé avec succès !"
puts "🔗 Vous pouvez maintenant visiter le tournoi à l'ID: #{tournament.id}"
