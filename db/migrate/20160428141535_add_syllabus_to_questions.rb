class AddSyllabusToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :syllabus, :string
  end
end
