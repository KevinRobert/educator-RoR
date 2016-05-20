class AddAllowRetryToTests < ActiveRecord::Migration
  def change
    add_column :tests, :allow_retry, :boolean, :default => true
  end
end
