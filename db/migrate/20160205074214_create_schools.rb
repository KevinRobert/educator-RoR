class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :name
      t.boolean :grade6
      t.boolean :grade7
      t.boolean :grade8
      t.boolean :grade9
      t.boolean :grade10
      t.boolean :grade11
      t.boolean :grade12
      t.string :address

      t.timestamps
    end

    School.create :name => 'Test School', :grade10 => true
  end
end
