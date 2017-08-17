class AddPublishedFlagToContentElements < ActiveRecord::Migration[5.1]
  def change
    add_column :content_fragments, :is_published, :boolean, default: false
    [:en, :de].each do |locale|
      ContentFragment.books(locale).first.update_attribute(:is_published, true)
    end
  end
end
