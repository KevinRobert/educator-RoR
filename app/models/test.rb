class Test < ActiveRecord::Base

  has_many :test_questions
  has_many :questions, through: :test_questions, dependent: :destroy
  has_many :section_tests, dependent: :destroy
  has_many :test_responses

  accepts_nested_attributes_for :section_tests

  # validation
  validates :name, :subject, :syllabus, :topic, :presence => true

  TOPICS = ["General","Science", "Physics",  "Chemistry", "Math"]

  # records per page
  self.per_page = 25

  # Search tests by syllabus, subject, grade and chapter
  def self.search(search_params)
    tests = Test.all
    tests = tests.where("syllabus = ?", search_params[:syllabus]) if search_params[:syllabus].present?
    tests = tests.where("grade = ?", search_params[:grade]) if search_params[:grade].present?
    tests = tests.where("subject = ?", search_params[:subject]) if search_params[:subject].present?
    tests = tests.where("topic = ?", search_params[:topic]) if search_params[:topic].present?

    tests
  end

  # get different question topics of a test
  def get_available_topics
    available_topics = []

    self.questions.each do |q|
      available_topics << q.topic unless available_topics.include? q.topic
    end

    available_topics
  end

  # get different question types included in a test
  def get_available_types
    available_types = []

    self.questions.each do |q|
      available_types << q.question_type unless available_types.include? q.question_type
    end

    available_types
  end

  # get different question topics of a test
  def get_available_subjects
    available_subjects = []

    self.questions.each do |q|
      available_subjects << q.subject unless available_subjects.include? q.subject
    end

    available_subjects
  end
  # get different question concepts of a test
  def get_available_concepts
    available_concepts = []

    self.questions.each do |q|
      available_concepts += q.concepts.split(',')
    end

    available_concepts = available_concepts.uniq - [""," "]
  end

end
