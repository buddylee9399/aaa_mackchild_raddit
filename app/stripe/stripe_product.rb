class StripeProduct
  attr_reader :params, :painting

  def initialize(params, painting)
    @params = params
    @painting = painting
  end

  def currency_options
    params
      .fetch(:currency_options, [])
      .inject({}) do |acc, option|
        acc[option[:currency]] = {unit_amount: (option[:amount].to_f * 100).to_i}
        acc
      end
  end

  def create_product
    return if painting.stripe_id.present?

    stripe_product = Stripe::Product.create({
      name: painting.title,
      description: painting.description,
      images: [
        # product.photo.representation(:medium).processed.url,
        "https://doodleipsum.com/700/flat?i=191258f28a3672a5589de78d98ac7967",
        # Rails.application.routes.url_helpers.rails_blob_path(product.photo, only_path: true),
        # url_for(product.photo),
        # the .url is beacuse the direct upload true
        # product.photo.url
      ],
      metadata: {
        user_id: 1,
        product_id: painting.id
      },      
      default_price_data: {
        currency: painting.currency,
        unit_amount: painting.amount,
        currency_options: currency_options
      },
      expand: ['default_price'],
    },)

    product.update(
      stripe_id: stripe_product.id,
      data: stripe_product.to_json,
      stripe_price_id: stripe_product.default_price.id,
    )
  end

end
