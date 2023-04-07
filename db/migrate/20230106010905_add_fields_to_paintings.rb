class AddFieldsToPaintings < ActiveRecord::Migration[7.0]
  def change
    add_column :paintings, :currency, :string, default: 'usd'
    add_column :paintings, :amount, :integer
  end
end
