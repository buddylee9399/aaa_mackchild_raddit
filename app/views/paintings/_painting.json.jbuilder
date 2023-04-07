json.extract! painting, :id, :title, :painter, :description, :stripe_id, :stripe_price_id, :data, :created_at, :updated_at
json.url painting_url(painting, format: :json)
