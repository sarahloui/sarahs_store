class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :first_name
      t.string :last_name
      t.string :address_street
      t.string :address_city
      t.string :address_state
      t.string :address_zip
      t.string :email
      t.string :phone_number
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
