class AppController < ApplicationController
  include TestEvaluation

  before_action :authenticate_user!

  def index
    if current_user.student? && current_user.section_id.present?
      redirect_to portal_index_path() and return
    else
      redirect_to dashboard_index_path() and return
    end
  end

end