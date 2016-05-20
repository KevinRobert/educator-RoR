class AddTimedColumnsToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :timed, :boolean
    add_column :questions, :timeout, :integer

    remove_column :tests, :is_timed
    remove_column :tests, :timeout
  end
end
