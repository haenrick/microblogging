class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :posts }

      t.timestamps
    end
  end
end
