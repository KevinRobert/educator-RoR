class AlterSectionColumnUsersTable < ActiveRecord::Migration
  def up
    remove_column :users, :section
    # remove_column :users, :grade
    # remove_column :users, :school_id
    add_column :users, :section_id, :integer
  end

  def down
    add_column :users, :section, :string
    # add_column :users, :grade, :string
    # add_column :users, :school_id, :integer
    remove_column :users, :section_id
  end
end
