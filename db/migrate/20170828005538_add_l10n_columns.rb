class AddLtrRtlAndLocaleColumnsToExercisesAndTextFragments < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :locale, :string
    rename_column :text_fragments, :text, :text_ltr
    rename_column :text_fragments, :key, :key_ltr
    add_column :text_fragments, :text_rtl, :string
    add_column :text_fragments, :key_rtl, :string
  end
end
