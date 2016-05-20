class AddSubjectFieldToTests < ActiveRecord::Migration
  def change
  	add_column :tests, :subject, :string
  end
end
