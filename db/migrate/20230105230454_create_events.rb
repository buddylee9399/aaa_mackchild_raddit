class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.json :data
      t.string :source
      t.text :processing_errors
      t.boolean :status

      t.timestamps
    end
  end
end
