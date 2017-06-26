class AddIsAdmin < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :is_admin, :boolean, default: false
  end
  # User.create(email: 'admin@surayt.com', password: '123123', password_confirmation: '123123', is_admin: true)
end
