class AddTimeToUserTests < ActiveRecord::Migration
  def up
    remove_column :user_tests, :finished_at
    add_column :user_tests, :time, :integer
    add_column :users, :section, :string
  end

  def down
    add_column :user_tests, :finished_at, :datetime
    remove_column :user_tests, :time
    remove_column :users, :section
  end
end
