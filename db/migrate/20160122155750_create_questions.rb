class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.belongs_to :test, index: true

      t.string :si_no
      t.string :subject
      t.string :topic
      t.string :question_type
      t.string :difficulty
      t.string :question

      t.string :option1
      t.string :option2
      t.string :option3
      t.string :option4

      t.string :concepts

      t.string :answer_type

      t.timestamps
    end
  end
end