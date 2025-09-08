class Admin::GamesController < Admin::BaseController
  before_action :set_tournament
  before_action :set_game, only: [:edit, :update]
  before_action :authorize_tournament_management!

  def edit
    @referees = @tournament.referees
  end

  def update
    # Préparer les paramètres de mise à jour
    update_params = game_params.except(:game_start_time)

    # Traiter l'heure séparément
    if params[:game][:game_start_time].present?
      time_parts = params[:game][:game_start_time].split(':')
      if time_parts.length == 2
        # Créer un datetime avec la date du tournoi et l'heure saisie
        game_datetime = @tournament.start_date.to_datetime + time_parts[0].to_i.hours + time_parts[1].to_i.minutes
        update_params[:game_start] = game_datetime
      end
    else
      update_params[:game_start] = nil
    end

    if @game.update(update_params)
      # Recharger le jeu pour avoir les données à jour
      @game.reload
      respond_to do |format|
        format.html { redirect_to admin_tournament_path(@tournament), notice: 'Match mis à jour avec succès.' }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("game_#{@game.id}", partial: "admin/tournaments/game_row", locals: { game: @game, tournament: @tournament })
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
