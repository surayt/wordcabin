class AddLocale < ActiveRecord::Migration[5.1]
  def change
    add_column :data_fragments, :locale, :string
  end
end
