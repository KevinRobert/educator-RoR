require 'csv'

class User < ActiveRecord::Base
  enum role: [:student, :school_employee, :school_admin, :website_admin]
  after_initialize :set_default_role, :if => :new_record?

  has_many :user_tests
  belongs_to :school, unscoped: true
  belongs_to :section

  validates :username, uniqueness: { case_sensitive: false }
  validates :school_id, :presence => true, :if => :is_not_admin?
  # validates :section_id, :presence => true, :if => :is_student?

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,# :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  default_scope { where(active: true) }

  GRADES = ["6th", "7th", "8th", "9th", "10th", "11th", "12th"]

  # Email shouldn't be mandatory
  def email_required?
    false
  end

  def email_changed?
    false
  end

  def set_default_role
    self.role ||= :student
  end

  def is_not_admin?
    true unless self.website_admin?
  end

  def is_student?
    true if self.student?
  end

  def self.import(file, current_user)
    i = 0;
    CSV.foreach(file.path, headers: true) do |line|

      row = line.to_hash.symbolize_keys!

      user = User.find_by_username(row[:UserName])
      section = Section.where(:school_id => current_user.school.try(:id), :name => row[:Section], :grade => row[:Grade]).try(:first)

      unless user.present?
        user = User.create(
          :name => row[:Name],
          :username => row[:UserName],
          :role => row[:Role],
          :grade => row[:Grade],
          :password => row[:Password].present? ? row[:Password] : row[:UserName].try(:downcase),
          :school_id => current_user.school.try(:id),
          :section_id => section.try(:id),
          :confirmed_at => Time.now,
          :contact_email => row[:ContactEmail]
        )
        # user.skip_confirmation!
        i = i + 1 if user.valid?
      else
        user.update_attributes(
          :name => row[:Name],
          :role => row[:Role],
          :grade => row[:Grade],
          :password => row[:Password].present? ? row[:Password] : row[:UserName].try(:downcase),
          :school_id => current_user.school.try(:id),
          :section_id => section.try(:id),
          :contact_email => row[:ContactEmail]
        )
        i = i + 1 if user.valid?
      end
    end

    i
  end

  # Get current user's recent test activities
  def recent_activities
    recent_tests = self.user_tests.where("status = ? and created_at > ?", "Finished", self.last_sign_in_at)
    unless recent_tests.present?
      recent_tests = self.user_tests.where(:status => "Finished").order(created_at: :asc).limit(1)
    end

    recent_tests
  end

  # Search tests by syllabus, subject, grade and chapter
  def self.search(search_params)
    users = User.unscoped
    users = users.where("role = ?", search_params[:role]) if search_params[:role].present?
    users = users.where("lower(name) LIKE ?", "%#{search_params[:name].downcase}%") if search_params[:name].present?
    users = users.where("school_id = ?", search_params[:school]) if search_params[:school].present?
    users = users.where("grade = ?", search_params[:grade]) if search_params[:grade].present?

    users
  end
end
