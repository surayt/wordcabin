class RenameDataFragments < ActiveRecord::Migration[5.1]
  def change
    rename_table :data_fragments, :content_fragments
  end
end
