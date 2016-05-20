class AddTopicFieldsToTests < ActiveRecord::Migration
  def change
    add_column :tests, :syllabus, :string
    add_column :tests, :topic, :string
    add_column :tests, :grade, :string
  end
end
