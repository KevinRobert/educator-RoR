class AddTimerColumnsToTests < ActiveRecord::Migration
  def change
    add_column :tests, :timeout, :integer
  end
end
