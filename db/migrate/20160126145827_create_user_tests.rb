class CreateUserTests < ActiveRecord::Migration
  def change
    create_table :user_tests do |t|
      t.belongs_to :user, index: :true
      t.belongs_to :test, index: :true

      t.string :status
      t.float :score
      t.datetime :finished_at

      t.timestamps
    end
  end
end
