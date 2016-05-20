class AddSolutionColumnToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :solution_description, :text
    change_column :questions, :question, :text
  end
end
