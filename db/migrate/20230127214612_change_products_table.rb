class ChangeProductsTable < ActiveRecord::Migration[7.0]
  def change
    change_table :products do |t|
      t.remove :status
      t.integer :number_sold
    end
  end
end
