class AddExercisesTables < ActiveRecord::Migration[5.1]
  def change
    create_table :exercises do |t|
      t.string :type
      t.string :name
      t.string :description
      t.string :text_fragment_order
    end

    create_table :text_fragments do |t|
      t.string :type
      t.string :text
      t.string :key
      t.integer :sort_order
      t.references :exercise
      t.references :question
    end
  end
end
