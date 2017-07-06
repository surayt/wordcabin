class AddSortingColumnToContentFragments < ActiveRecord::Migration[5.1]
  def change
    add_column :content_fragments, :chapter_padded, :string
    add_index :content_fragments, :chapter_padded
  end
end
