class AddRandomOrderToUserTests < ActiveRecord::Migration
  def change
    add_column :user_tests, :random_order, :string
  end
end
