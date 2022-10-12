class ChangeOrdersTable < ActiveRecord::Migration[7.0]
  def change
    change_table :orders do |t|
      t.rename :first_name, :name
      t.rename :last_name, :address_line1
      t.rename :address_street, :address_line2
      t.string :checkout_session
    end
  end
end