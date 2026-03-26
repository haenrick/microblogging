class AddPublicIdToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :public_id, :string
    add_index :posts, :public_id, unique: true

    # Backfill existing posts
    Post.find_each { |p| p.update_column(:public_id, SecureRandom.urlsafe_base64(8)) }

    change_column_null :posts, :public_id, false
  end
end
