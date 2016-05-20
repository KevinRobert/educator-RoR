class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.string :name
      t.boolean :is_timed, default: false
      t.integer :timeout
      
      t.timestamps
    end
  end
end
