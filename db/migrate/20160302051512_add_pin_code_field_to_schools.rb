class AddPinCodeFieldToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :pin_code, :string
  end
end
