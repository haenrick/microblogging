class AddPrivateProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :private_profile, :boolean, default: false, null: false
  end
end
