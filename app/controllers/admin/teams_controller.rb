class Admin::TeamsController < Admin::BaseController
  before_action :set_tournament
  before_action :authorize_tournament_management!

  def create
    @team = @tournament.teams.build(team_params)

    if @team.save
      redirect_to admin_tournament_path(@tournament), notice: 'Équipe ajoutée avec succès.'
    else
      error_messages = @team.errors.full_messages.join(', ')
      redirect_to admin_tournament_path(@tournament), alert: "Erreur lors de l'ajout de l'équipe: #{error_messages}"
    end
  end

  def edit
    @team = @tournament.teams.find(params[:id])
  end

  def update
    @team = @tournament.teams.find(params[:id])

    if @team.update(team_params)
      redirect_to admin_tournament_path(@tournament), notice: 'Équipe mise à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @team = @tournament.teams.find(params[:id])
    @team.destroy
    redirect_to admin_tournament_path(@tournament), notice: 'Équipe supprimée avec succès.'
  end

  def assign_team_to_pool
    @team = @tournament.teams.find(params[:id])
    pool = @tournament.pools.find(params[:pool_id])

    if @team.update(pool: pool)
      respond_to do |format|
        format.html { redirect_to admin_tournament_path(@tournament), notice: "#{@team.name} assignée à #{pool.name}." }
        format.turbo_stream {
          redirect_to admin_tournament_path(@tournament), notice: "#{@team.name} assignée à #{pool.name}."
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_tournament_path(@tournament), alert: 'Erreur lors de l\'assignation.' }
        format.turbo_stream { head :unprocessable_entity }
      end
    end
  end

  def remove_team_from_pool
    @team = @tournament.teams.find(params[:id])
    pool = @team.pool
    pool_name = pool&.name

    if @team.update(pool: nil)
      respond_to do |format|
        format.html { redirect_to admin_tournament_path(@tournament), notice: "#{@team.name} retirée de #{pool_name}." }
        format.turbo_stream {
          redirect_to admin_tournament_path(@tournament), notice: "#{@team.name} retirée de #{pool_name}."
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_tournament_path(@tournament), alert: 'Erreur lors du retrait.' }
        format.turbo_stream { head :unprocessable_entity }
      end
    end
  end

  def remove_photo
    @team = @tournament.teams.find(params[:id])
    @team.photo.purge if @team.photo.attached?
    redirect_to edit_admin_tournament_team_path(@tournament, @team), notice: 'Photo supprimée avec succès.'
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def team_params
    params.require(:team).permit(:name, :color, :description, :photo)
  end
end
