class CreateTestResponses < ActiveRecord::Migration
  def change
    create_table :test_responses do |t|
      t.belongs_to :user, index: true
      t.belongs_to :test, index: true
      t.belongs_to :question, index: true

      t.string :answer_options
      t.string :answer_value
      t.float :answer_time
      t.float :answer_score

      t.timestamps
    end
  end
end
