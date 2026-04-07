class CreateErrorLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :error_logs do |t|
      t.string  :error_class,  null: false
      t.text    :message,      null: false
      t.text    :backtrace
      t.string  :controller
      t.string  :action
      t.string  :path
      t.string  :http_method
      t.text    :params_json
      t.bigint  :user_id
      t.string  :fingerprint,  null: false

      t.timestamps
    end

    add_index :error_logs, :fingerprint
    add_index :error_logs, :created_at
    add_index :error_logs, :error_class
  end
end
