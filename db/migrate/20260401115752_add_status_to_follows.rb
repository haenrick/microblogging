class AddStatusToFollows < ActiveRecord::Migration[8.1]
  def change
    add_column :follows, :status, :string, default: "accepted", null: false
    add_index :follows, :status
  end
end
