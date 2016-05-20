class Admin::SyllabusesController < ApplicationController

  before_action :authenticate_user!
  helper_method :sort_column, :sort_direction

  load_and_authorize_resource

  # Save previous page url
  before_filter "save_previous_url", only: [:new, :edit]

  def new
    @syllabus = Syllabus.new
    @back_url = session[:my_previous_url]

    render 'edit'
  end

  def create
    @back_url = session[:my_previous_url]

    @syllabus = Syllabus.new syllabus_params
    if @syllabus.save
      redirect_to @back_url, :notice => "Syllabus was created successfully."
    else
      flash[:error] = @syllabus.errors.full_messages
      render 'edit'
    end
  end

  def index
    if params[:sort].present?
      @syllabuses = Syllabus.search(params)
                  .order(sort_column + ' ' + sort_direction)
                  .paginate(:page => params[:page])
    else
      @syllabuses = Syllabus.search(params).order('id ASC').paginate(:page => params[:page])
    end
  end

  def edit
    @syllabus = Syllabus.find(params[:id])
    @back_url = session[:my_previous_url]
  end

  def update
    @syllabus = Syllabus.find(params[:id])
    @back_url = session[:my_previous_url]

    if @syllabus.update_attributes(syllabus_params)
      redirect_to @back_url, :notice => "Syllabus was updated."
    else
      render 'edit', :alert => @syllabus.errors.full_messages
    end
  end

  def destroy
    @syllabus = Syllabus.find(params[:id])
    @back_url = session[:my_previous_url]
    @syllabus.destroy
    
    redirect_to @back_url, :notice => "Syllabus was deleted successfully."
  end

  # Save previous page url into session
  def save_previous_url
    url = request.env['HTTP_REFERER'] || ''
    session[:my_previous_url] = url unless url.include?("/admin/tests/")
  end

  private

  def syllabus_params
    params.require(:syllabus).permit(:syllabus, :grade, :subject, :topic, :concept)
  end

  def sort_column
    Syllabus.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end