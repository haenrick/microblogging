class AddLinkPreviewToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :link_preview, :jsonb
  end
end
