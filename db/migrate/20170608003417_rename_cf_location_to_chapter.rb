class RenameCfLocationToChapter < ActiveRecord::Migration[5.1]
  def change
    rename_column :content_fragments, :location, :chapter
  end
end
