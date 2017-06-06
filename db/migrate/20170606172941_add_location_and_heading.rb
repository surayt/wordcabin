class AddLocationAndHeading < ActiveRecord::Migration[5.1]
  def change
    add_column :data_fragments, :location, :string
    add_column :data_fragments, :heading,  :string
  end
end
