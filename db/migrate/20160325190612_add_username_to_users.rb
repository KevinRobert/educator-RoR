class AddUsernameToUsers < ActiveRecord::Migration
  def up
    add_column :users, :username, :string
    add_column :users, :contact_email, :string
    add_index :users, :username, unique: true

    remove_index :users, :email
  end

  def down
    remove_column :users, :username
    remove_column :users, :contact_email

    add_index :users, :email, unique: true
  end
end
