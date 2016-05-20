class RegistrationsController < Devise::RegistrationsController

  def new
    @schools = School.active
    super
  end

  def create
    @schools = School.active
    super
  end

  def edit
    @schools = School.active
    super
  end

  def update
    @schools = School.active
    super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:name, :username, :contact_email, :password, :password_confirmation, :school_id)
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:name, :username, :contact_email, :password, :password_confirmation, :current_password, :school_id)
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :username, :contact_email, :password, :password_confirmation, :school_id)
  end

  def account_update_params
    params.require(:user).permit(:name, :username, :contact_email, :password, :password_confirmation, :current_password, :school_id)
  end
end