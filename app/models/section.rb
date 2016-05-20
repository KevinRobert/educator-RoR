class Section < ActiveRecord::Base

  belongs_to :school
  has_many :users
  has_many :section_tests, dependent: :destroy
  has_many :tests, through: :section_tests, dependent: :destroy

end