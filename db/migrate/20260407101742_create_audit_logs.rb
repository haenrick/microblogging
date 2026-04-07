class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.references :admin,  null: false, foreign_key: { to_table: :users }
      t.string     :action, null: false
      t.string     :target_type
      t.bigint     :target_id
      t.string     :target_label
      t.text       :details

      t.timestamps
    end

    add_index :audit_logs, :created_at
    add_index :audit_logs, :action
  end
end
