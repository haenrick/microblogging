class CreateInvites < ActiveRecord::Migration[8.1]
  def change
    create_table :invites do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :used_by, null: true,  foreign_key: { to_table: :users }
      t.string     :token,   null: false, index: { unique: true }
      t.datetime   :used_at
      t.datetime   :expires_at

      t.timestamps
    end
  end
end
