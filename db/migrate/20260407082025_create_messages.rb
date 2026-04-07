class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.bigint :sender_id, null: false
      t.bigint :recipient_id, null: false
      t.text :content, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, :sender_id
    add_index :messages, :recipient_id
    add_index :messages, [ :sender_id, :recipient_id ]

    add_foreign_key :messages, :users, column: :sender_id
    add_foreign_key :messages, :users, column: :recipient_id
  end
end
