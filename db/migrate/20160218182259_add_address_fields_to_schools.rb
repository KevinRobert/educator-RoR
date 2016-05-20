class AddAddressFieldsToSchools < ActiveRecord::Migration
  def change
    rename_column :schools, :address, :address1

    add_column :schools, :address2, :string
    add_column :schools, :city, :string
    add_column :schools, :state, :string
    add_column :schools, :admin_id, :integer
    add_column :schools, :active, :boolean, :default => true
  end
end
