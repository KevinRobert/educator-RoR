class CreateSectionTests < ActiveRecord::Migration
  def change
    create_table :section_tests do |t|
      t.integer :section_id
      t.integer :test_id
      t.datetime :start_at
      t.datetime :end_at
    end
  end
end
