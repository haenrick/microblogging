class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.bigint  :recipient_id,     null: false
      t.bigint  :actor_id,         null: false
      t.string  :notifiable_type,  null: false
      t.bigint  :notifiable_id,    null: false
      t.string  :notification_type, null: false
      t.datetime :read_at

      t.timestamps
    end
    add_index :notifications, :recipient_id
    add_index :notifications, :actor_id
    add_index :notifications, [ :notifiable_type, :notifiable_id ]
  end
end
