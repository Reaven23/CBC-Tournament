class Admin::GamesController < Admin::BaseController
  before_action :set_tournament
  before_action :set_game, only: [:edit, :update]
  before_action :authorize_tournament_management!

  def edit
    @referees = @tournament.referees
  end

  def update
    if @game.update(game_params)
      respond_to do |format|
        format.html { redirect_to admin_tournament_path(@tournament), notice: 'Match mis à jour avec succès.' }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("game_#{@game.id}", partial: "admin/tournaments/game_row", locals: { game: @game })
        }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("game_modal_#{@game.id}", partial: "admin/tournaments/game_modal_content", locals: { game: @game, tournament: @tournament, referees: @tournament.referees })
        }
      end
    end
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def set_game
    @game = @tournament.games.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:game_start, :court_number, :home_score, :away_score, referee_ids: [])
  end
end
