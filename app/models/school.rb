class School < ActiveRecord::Base
  has_many :users, unscoped: true
  has_many :sections, dependent: :destroy
  belongs_to :admin, :class_name => "User", :foreign_key => "admin_id"

  validates :name, :presence => true

  scope :active, -> { where(active: true) }

  # records per page
  self.per_page = 25

  def available_grades
    available_grades = []
    (6..12).each do |idx|
      if self.send("grade#{idx}")
        available_grades << "#{idx}th"
      end
    end

    available_grades
  end
  
end