class AddLinkPreviewToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :link_preview, :jsonb
  end
end
