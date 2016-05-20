class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.integer :school_id
      t.string :name
      t.string :grade
    end
  end
end
