class AddGradeFieldToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :grade, :string
  end
end
