class Admin::UsersController < ApplicationController

  before_action :authenticate_user!
  helper_method :sort_column, :sort_direction

  load_and_authorize_resource

  # Save previous page url
  before_filter "save_previous_url", only: [:new, :edit]

  def new
    @user = User.new

    @back_url = session[:my_previous_url]

    if current_user.website_admin?
      @schools = School.active
    else
      @schools = []
      @schools << current_user.school
    end
    @available_grades = @schools.first.present? ? @schools.first.available_grades : []
    #@sections = Section.where(:school_id => @schools.first.id, :grade => @available_grades[0])
    @sections = []
    
    render 'edit'
  end

  def create
    @back_url = session[:my_previous_url]

    user_params = secure_params
    if user_params[:role] == "website_admin"
      user_params.delete("grade")
      user_params.delete("section_id")
      user_params.delete("school_id")
    elsif user_params[:role] == "school_admin" || user_params[:role] == "school_employee"
      user_params.delete("grade")
      user_params.delete("section_id")
    end

    @user = User.new user_params
    # @user.skip_confirmation!

    unless user_params[:school_id].present?
      @user.attributes = { 
        school_id: (current_user.school.present? ? current_user.school.id : nil),
      }
    end
    @user.attributes = { password: user_params[:username] }

    if @user.save
      redirect_to @back_url, :notice => "User created successfully."
    else
      @schools = School.active
      @available_grades = current_user.school.present? ? current_user.school.available_grades : []
      user_section @user

      render 'edit', :alert => @user.errors.full_messages
    end
 
  end

  def index
    school = nil
    @users = []

    if current_user.try(:website_admin?)
      @users = User.search(params).paginate(:page => params[:page])
    else
      school = current_user.school

      if school.present?
        if params[:sort].present?
          @users = User.search(params).where(school_id: school.id)
                      .order(sort_column + ' ' + sort_direction)
                      .paginate(:page => params[:page])
        else
          @users = User.search(params).where(school_id: school.id).paginate(:page => params[:page])
        end
      else
        @users = User.search(params).where(:id => nil, :active => true).where("id IS NOT ?", nil).paginate(:page => params[:page])
      end
    end

    @schools = School.active
  end

  def edit
    @user = User.unscoped.find(params[:id])

    @back_url = session[:my_previous_url]

    user_section @user

    if @user.school.present?
      @available_grades = @user.school.available_grades.present? ? @user.school.available_grades : []
 #     @sections = Section.where(:school_id => @user.school.id, :grade => @user.grade)
    else
      @available_grades = []
#      @sections = []
    end

    


  end

  def update
    @user = User.unscoped.find(params[:id])

    @back_url = session[:my_previous_url]

    user_params = secure_params
    if user_params[:role] == "website_admin"
      user_params.delete("grade")
      user_params.delete("section_id")
      user_params.delete("school_id")
    elsif user_params[:role] == "school_admin" || user_params[:role] == "school_employee"
      user_params.delete("grade")
      user_params.delete("section_id")
    end

    if @user.update_attributes(user_params)
      redirect_to @back_url, :notice => "User updated."
    else
      user_section @user
      if @user.school.present?
        @available_grades = @user.school.available_grades.present? ? @user.school.available_grades : []
#        @sections = Section.where(:school_id => @user.school.id, :grade => @user.grade)
      else
        @available_grades = []
#        @sections = []
      end
      render 'edit', :alert => "Unable to update user."
    end
  end

  def destroy
    user = User.unscoped.find(params[:id])

    user.destroy
    redirect_to admin_users_path, :notice => "User deleted."
  end

  def disable
    @user = User.unscoped.find(params[:user_id])
    @user.update_attributes :active => !@user.active

    respond_to do |format|
      if @user.valid?
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

  def import
    rows = User.import(params[:file], current_user)
    redirect_to admin_users_path, notice: "#{rows} users imported."
  end

  # Save previous page url into session
  def save_previous_url
    session[:my_previous_url] = request.env['HTTP_REFERER'] || ''
  end

  def get_sections
    available_sections = Section.where(:school_id => params[:school], :grade => params[:grade]) 
    render json: {:sections => available_sections.to_json}, status: :created and return
  end

  private

  def user_section(user)
    @sections = Section.where(:school_id => user.school_id, :grade => user.grade) 
  end

  def user_params
    params.require(:user).permit(:name,:username, :contact_email, :role, :grade, :school_id, :section_id)
  end

  def secure_params
    params.require(:user).permit(:name, :username, :contact_email, :role, :grade, :school_id, :section_id, :contact_email)
  end

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end