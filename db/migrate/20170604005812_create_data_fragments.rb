class CreateDataFragments < ActiveRecord::Migration[5.1]
  def change
    create_table :data_fragments do |t|
      t.string :path
      t.string :html
    end
  end
end
