class AddGradeToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :grade, :string
  end
end
