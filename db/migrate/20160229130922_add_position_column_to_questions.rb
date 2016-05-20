class AddPositionColumnToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :position, :integer
  end
end
