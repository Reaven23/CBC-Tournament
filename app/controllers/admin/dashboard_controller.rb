class Admin::DashboardController < Admin::BaseController
  def index
    @tournaments = if current_user.super_admin?
                     Tournament.includes(:user, :pools, :teams).order(created_at: :desc).limit(10)
                   else
                     current_user.tournaments.includes(:pools, :teams).order(created_at: :desc).limit(10)
                   end

    tournament_ids = @tournaments.map(&:id)

    @recent_games = if tournament_ids.any?
                      Game.includes(:tournament, :home_team, :away_team)
                          .where(tournament_id: tournament_ids)
                          .order(updated_at: :desc)
                          .limit(5)
                    else
                      Game.none
                    end

    @stats = {
      total_tournaments: Tournament.count,
      active_tournaments: Tournament.active.count,
      total_games: Game.count,
      completed_games: Game.where(status: 'played').count
    }
  end
end
