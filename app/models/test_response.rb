class TestResponse < ActiveRecord::Base

  belongs_to :user
  belongs_to :test
  belongs_to :question
  belongs_to :user_test

  validates :user_id, :test_id, :question_id, :answer_time, :user_test_id, :presence => true

  def answer_options=(values)
    write_attribute(:answer_options, values.map(&:to_i))
  end

end