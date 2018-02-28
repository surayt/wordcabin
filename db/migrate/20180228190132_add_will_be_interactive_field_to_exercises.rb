class AddWillBeInteractiveFieldToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :will_be_interactive, :boolean, default: true
  end
end
