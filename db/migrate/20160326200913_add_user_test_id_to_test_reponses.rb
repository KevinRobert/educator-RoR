class AddUserTestIdToTestReponses < ActiveRecord::Migration
  def change
    add_column :test_responses, :user_test_id, :integer
  end
end
