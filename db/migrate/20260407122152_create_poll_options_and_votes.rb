class CreatePollOptionsAndVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :poll_options do |t|
      t.references :post, null: false, foreign_key: true
      t.string  :text, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :poll_votes do |t|
      t.references :poll_option, null: false, foreign_key: true
      t.references :user,        null: false, foreign_key: true
      t.timestamps
    end
    add_index :poll_votes, [:user_id, :poll_option_id], unique: true
  end
end
