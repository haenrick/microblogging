class AddExpiresAtToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :expires_at, :datetime
    add_index :posts, :expires_at
  end
end
