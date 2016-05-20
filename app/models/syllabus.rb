class Syllabus < ActiveRecord::Base
  validates :syllabus, :grade, :subject, :topic, :concept,:presence => true

  SYLLABUSES = ["ACT", "CBSE", "Foundation", "JEE"]
  SUBJECTS = ["Biology", "Chemistry", "English", "Mathematics", "Physics","Science","General"]

  # Search by syllabus, subject and grade
  def self.search(search_params)
    syllabuses = Syllabus.all
    syllabuses = syllabuses.where("syllabus = ?", search_params[:syllabus]) if search_params[:syllabus].present?
    syllabuses = syllabuses.where("grade = ?", search_params[:grade]) if search_params[:grade].present?
    syllabuses = syllabuses.where("subject = ?", search_params[:subject]) if search_params[:subject].present?

    syllabuses
  end
end