class AddSchoolIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :school_id, :integer
    add_column :questions, :image_temp_name, :string
  end
end
