class CreateOffers < ActiveRecord::Migration[7.0]
  def change
    create_table :offers do |t|
      t.integer :status
      t.boolean :current
      t.timestamp :start_time
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end
  end
end
