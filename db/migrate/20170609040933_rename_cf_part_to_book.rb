class RenameCfPartToBook < ActiveRecord::Migration[5.1]
  def change
    rename_column :content_fragments, :part, :book
  end
end
