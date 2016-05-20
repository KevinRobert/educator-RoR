class UserTest < ActiveRecord::Base

  belongs_to :user
  belongs_to :test
  has_many :test_responses

  scope :finished, -> { where(status: "Finished") }
  scope :in_progress, -> { where("status IN (?)", ["In progress", "Started"]) }

  FINISHED = "Finished"
  IN_PROGRESS = "In progress"
  STARTED = "Started"

  # Search test results by subject and chapter
  def self.search(search_params, user_id)
    results = UserTest.joins(:test).where(:user_id => user_id, :status => "Finished")
    results = results.where(tests: {subject: search_params[:subject]}) if search_params[:subject].present?
    results = results.where(tests: {topic: search_params[:chapter]}) if search_params[:chapter].present?

    results
  end

  def unanswered_questions
    questions_all = self.test.questions.pluck(:id).sort
    questions_taken = TestResponse.where(:user_test_id => self.id)
                                  .where("answer_options <> '' and answer_options <> '[]'")
                                  .pluck(:question_id)
    available_questions = questions_all - questions_taken

    available_questions
  end
end