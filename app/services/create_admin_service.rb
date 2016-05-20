class CreateAdminService
  def call
    user = User.find_or_create_by!(username: Rails.application.secrets.admin_username) do |user|
        user.password = Rails.application.secrets.admin_password
        user.password_confirmation = Rails.application.secrets.admin_password
        user.confirm!
        user.admin!
      end
  end
end
