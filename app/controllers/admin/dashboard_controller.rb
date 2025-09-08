class Admin::DashboardController < Admin::BaseController
  def index
    @tournaments = if current_user.super_admin?
                     Tournament.includes(:user, :pools, :teams).order(created_at: :desc).limit(10)
                   else
                     current_user.tournaments.includes(:pools, :teams).order(created_at: :desc).limit(10)
                   end

    @recent_games = Game.includes(:tournament, :home_team, :away_team)
                       .where(tournament: @tournaments.map(&:id))
                       .order(updated_at: :desc)
                       .limit(5)

    @stats = {
      total_tournaments: @tournaments.count,
      active_tournaments: Tournament.active.count,
      total_games: Game.where(tournament: @tournaments.map(&:id)).count,
      completed_games: Game.where(tournament: @tournaments.map(&:id), status: 'played').count
    }
  end
end
