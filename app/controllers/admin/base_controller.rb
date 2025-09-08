class Admin::BaseController < ApplicationController
  include Authorization

  before_action :authenticate_user!
  before_action :authenticate_organizer_or_super_admin!

  layout 'admin'

  private

  def set_admin_breadcrumb
    add_breadcrumb "Administration", admin_root_path
  end
end
