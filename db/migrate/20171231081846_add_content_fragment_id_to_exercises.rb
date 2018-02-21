class AddContentFragmentIdToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :content_fragment_id, :integer
  end
end
