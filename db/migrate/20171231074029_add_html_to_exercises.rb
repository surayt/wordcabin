class AddHtmlToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :html, :text
  end
end
