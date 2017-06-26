class CreateFileAttachmentsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :file_attachments do |t|
      t.string :filename
      t.string :content_type
      t.binary :binary_data
    end
  end
end
