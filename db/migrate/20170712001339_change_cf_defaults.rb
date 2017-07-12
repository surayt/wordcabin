class ChangeCfDefaults < ActiveRecord::Migration[5.1]
  def change
    change_column_default :content_fragments, :heading, '<table><tr><td></td></tr></table>'
  end
end
