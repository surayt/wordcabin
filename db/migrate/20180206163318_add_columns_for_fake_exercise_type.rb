class AddColumnsForFakeExerciseType < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :content_fragment_id, :integer, null: true
    add_column :exercises, :sort_order, :integer, null: true
    add_column :exercises, :html, :text, null: true
    Exercise.where(locale: nil).update_attribute(:locale, :en)
  end
end
