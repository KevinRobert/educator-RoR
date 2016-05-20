class AddReportByToTests < ActiveRecord::Migration
  def change
    add_column :tests, :report_by, :string, :default => "Topic"
  end
end
