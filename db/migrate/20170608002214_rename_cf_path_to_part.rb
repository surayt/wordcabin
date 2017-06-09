class RenameCfPathToPart < ActiveRecord::Migration[5.1]
  def change
    rename_column :content_fragments, :path, :part
  end
end
