class AddDescriptionColumnToTests < ActiveRecord::Migration
  def change
    add_column :tests, :description, :text
  end
end
