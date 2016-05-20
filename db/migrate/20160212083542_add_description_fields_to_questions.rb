class AddDescriptionFieldsToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :description_title, :string
    add_column :questions, :description, :text
  end
end
