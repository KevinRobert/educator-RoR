class AddAnswersFieldsToUserTests < ActiveRecord::Migration
  def change
    add_column :user_tests, :total_questions, :integer
    add_column :user_tests, :correct_answers, :integer
  end
end
