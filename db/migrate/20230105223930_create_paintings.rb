class CreatePaintings < ActiveRecord::Migration[7.0]
  def change
    create_table :paintings do |t|
      t.string :title, null: false
      t.string :painter
      t.text :description
      t.string :stripe_id
      t.string :stripe_price_id
      t.json :data

      t.timestamps
    end
  end
end
