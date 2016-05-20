class Admin::SchoolsController < ApplicationController
  helper_method :sort_column, :sort_direction

  before_action :authenticate_user!

  load_and_authorize_resource

  def new
    @school = School.new
    render 'edit'
  end

  def index
    if params[:sort].present? && params[:sort] == 'admin'
      @schools = School.includes(:admin).all
                      .order('users.username ' + sort_direction)
                      .paginate(:page => params[:page])
    elsif params[:sort].present?
      @schools = School.all
                      .order(sort_column + ' ' + sort_direction)
                      .paginate(:page => params[:page])
    else
      @schools = School.all.order('name ASC').paginate(:page => params[:page])
    end
  end

  def create
    @school = School.new permit_params
    if @school.save
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def edit
    @school = School.find(params[:id])
    @school_grades = @school.available_grades
  end

  def update
    @school = School.find(params[:id])
    @school.update_attributes permit_params

    if @school.valid?
      flash[:success] = true
      redirect_to action: 'index'
    else
      flash[:success] = false
      flash[:message] = @school.errors.full_messages

      render 'edit'
    end
  end

  def disable
    @school = School.find(params[:school_id])
    @school.update_attributes :active => !@school.active

    respond_to do |format|
      if @school.valid?
        # Set active status to users of current school
        @school.users.each do |school_user|
          school_user.update_attributes :active => @school.active
        end

        format.html {}
        format.js { render json: {}, status: :created }
        format.json { render json: {}, status: :created }
      else
        format.html {}
        format.js { render json: {}, status: :unprocessable_entity }
        format.json { render json: {}, status: :unprocessable_entity }
      end  
    end
    
  end

  def get_sections
    school_sections = Section.where(:school_id => params[:school_id])
    render json: {:sections => school_sections.to_json}, status: :created and return
  end

  def get_grades
    school = School.find(params[:school_id])
    render json: {:grades => school.available_grades.to_json}, status: :created and return
  end

  def update_section
    @school = School.find(params[:school_id])
    Section.find_or_create_by(:school_id => @school.id, :grade => params[:grade], :name => params[:section])

    @school_grades = @school.available_grades

    render 'edit'
  end

  def destroy_grade_section
    section = Section.find_by_id(params[:section_id])
    @school = section.school
    section.destroy

    redirect_to edit_admin_school_path(@school), :notice => "Grade section was deleted."
  end

  private

  def sort_column
    (School.column_names.include?(params[:sort]) || params[:sort] == 'admin') ? params[:sort] : 'id'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def school_params
    params.require(:school).permit(:name, :grade6, :grade7, :grade8, :grade9, :grade10, :grade11, :grade12, :address1, :address2, :city, :state, :admin_id, :pin_code)
  end  

  def permit_params
    params.require(:school).permit(:name, :grade6, :grade7, :grade8, :grade9, :grade10, :grade11, :grade12, :address1, :address2, :city, :state, :admin_id, :pin_code)
  end
end