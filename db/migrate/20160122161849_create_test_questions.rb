class CreateTestQuestions < ActiveRecord::Migration
  def change
    create_table :test_questions do |t|
      t.belongs_to :test, index: true
      t.belongs_to :question, index: true

      t.timestamps
    end
  end
end
