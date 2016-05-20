class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # If the user authorization fails, redirec to home page
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  protected

  # Reroute after sign-in and sign-out
  def after_sign_in_path_for(resource)
  	app_index_path
  end
end
