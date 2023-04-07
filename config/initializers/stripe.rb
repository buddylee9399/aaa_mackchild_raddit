# Stripe.api_key = Rails.application.credentials.stripe[:secret]
Stripe.api_key = Rails.application.credentials[:development][:stripe][:private_key]
