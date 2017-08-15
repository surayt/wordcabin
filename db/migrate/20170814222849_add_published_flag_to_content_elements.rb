class AddPublishedFlagToContentElements < ActiveRecord::Migration[5.1]
  def change
    add_column :content_fragments, :is_published, :boolean, default: false
  end
end
