class CreateHashtags < ActiveRecord::Migration[8.1]
  def change
    create_table :hashtags do |t|
      t.string :name, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :post_hashtags do |t|
      t.references :post,    null: false, foreign_key: true
      t.references :hashtag, null: false, foreign_key: true
      t.timestamps
    end
    add_index :post_hashtags, [:post_id, :hashtag_id], unique: true
  end
end
