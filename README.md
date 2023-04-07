# THINGS IN HERE

## GEMS

```
gem 'bootstrap-sass', '~> 3.4', '>= 3.4.1'
gem 'devise'
gem 'acts_as_votable'
gem 'simple_form'
```
- really only used acts as votable and devise
- devise set for turbo, rails 7
- from: https://dev.to/efocoder/how-to-use-devise-with-turbo-in-rails-7-9n9

## MODELS
- devise user
- user has many links
- links scaffold, with comments on the show page
- links act as votable
- link has many comments, belongs to user
- comment belongs to link and user

## OTHER
- although bootstrap sass installed, it wasn't used for any stylings
- used button_to for the acts as votable links

## THE END

### ADDING THE ABILITY TO SELL A PRODUCT
- from cj avilla
- https://www.youtube.com/watch?v=MwbmKqdDsyI&list=PLS6F722u-R6IJfBrIRx3a2SBkAL4vUp2p&index=2
#### adding stripe info
- bundle add stripe
- EDITOR="subl --wait" rails credentials:edit
```
development:
  stripe:
    # publication key:
    public_key: 1234
    # secret key:
    private_key: 1234
    # for the webhooks
    signing_secret: 12341234
```

- create config/ini/stripe.rb
```
# Stripe.api_key = Rails.application.credentials.stripe[:secret]
Stripe.api_key = Rails.application.credentials[:development][:stripe][:private_key]
```

- add to the layouts app: head

```
<script src="https://js.stripe.com/v3/"></script>  
```

- testing to see if stripe is connected

```
- rails c
- Rails.application.credentials[:development][:stripe][:private_key]
- list = Stripe::Customer.list() - to see if it works- IT WORKS
```

- ADDING EVENT MODEL
- rails g model Event data:json source processing_errors:text status:boolean (he used status:enum with postgres)
- he updated the migration for postgres, i didnt
```
  def change
    create_enum :status, %w[
      pending
      processing
      processed
      failed
    ]
    create_table :events do |t|
      t.json :data
      t.string :source
      t.text :processing_errors
      t.enum(
        :status,
        enum_type: 'status',
        default: 'pending',
        null: false
      )
      t.timestamps
    end
  end
end
```

- ADDING WEBHOOKS
- rails g controller Webhooks
- update the file

```
class WebhooksController < ApplicationController
	skip_before_action :verify_authenticity_token

	def create
		event = Event.create!(
			data: params,
			source: params[:source]
		)
		logger.debug "This is event #{event}"
		# HandleEventJob.perform_later(event)
		render json: { status: :ok }
	end
end
```

- update routes

```
post '/webhooks/:source', to: 'webhooks#create'
```

- in a terminal window, we need the webhooks secret
```
stripe listen --forward-to localhost:3000/webhooks/stripe
```

- testing webhooks
- in terminal:  curl -X POST localhost:3000/webhooks/curl -d '{"data":"data"}'
- comes back: {"status":"ok"}
- in server logs
```
  ↳ app/controllers/webhooks_controller.rb:5:in `create'
  TRANSACTION (2.1ms)  commit transaction
  ↳ app/controllers/webhooks_controller.rb:5:in `create'
This is event #<Event:0x00007fbe1b9bb410>
Completed 200 OK in 36ms (Views: 0.4ms | ActiveRecord: 4.5ms | Allocations: 17778)
```
- rails c
```
Event.count
e = Event.first
e
EVENT WAS CREATED
```

- CREATING THE HANDLE EVENT JOB
- rails g job HandleEvent
- update the file

```
class HandleEventJob < ApplicationJob
  queue_as :default

  def perform(event)
    # puts "The source is #{event.source}"
    case event.source
    when 'stripe'
      handle_stripe_event(event)
    end
  end

  def handle_stripe_event(event)
    puts "The source is #{event.source}"
  end
end
```

- update webhooks controller to call the handle event job
```
		HandleEventJob.perform_later(event)
		render json: { status: :ok }
	end
end
```

- EVERYTHING WORKS

#### adding active storage
- rails active_storage:install
- rails db:migrate

#### Product. add it to stripe
- rails g scaffold Painting title painter description:text stripe_id stripe_price_id data:json
- update migration
```
t.string :title, null: false
```
- update painting.rb

```
has_one_attached :image
```
- rails g migration add_fields_to_paintings currency amount:integer
- update the migration
```
    add_column :paintings, :currency, :string, default: 'usd'
    add_column :paintings, :amount, :integer
```

- update paintings controller
```
      params.require(:painting).permit(:title, :painter, :description, :image, :currency, :amount)
```
- update the form
```
  <div class="form-inputs">
    <%= f.input :title %>
    <%= f.input :painter %>
    <%= f.input :description %>
    <%= f.input :currency, 
              value: "usd" %>
    <%= f.input :amount %>              
    <%= f.input :image, direct_upload: true %>
  </div>
```
- update painting partial page

```
  <p>
    <%= image_tag painting.image %>
  </p>
```
- refresh and create a product
- IT WORKED
- rails c
```
p = Painting.first
p
(we can see no stripe id, price id, data json object)
```
- add user authentication for paintings except index, show in controller
```
  before_action :authenticate_user!, except: [:index, :show]
```

#### LINKING PRODUCT WITH STRIPE
- update painting create with stripe api call
```
    respond_to do |format|
      if @painting.save
        service = StripeProduct.new(params, @painting)
        service.create_product
        format.html { redirect_to painting_url(@painting), notice: "Painting was successfully created." }
        format.json { render :show, status: :created, location: @painting }
      else
```

- create the folder app/stripe
- create the file stripe/stripe_product
```
class StripeProduct
	attr_reader :params, :painting

	def initialize(params, painting)
		@params = params
		@painting = painting
	end

  # def currency_options
  #   params
  #     .fetch(:currency_options, [])
  #     .inject({}) do |acc, option|
  #       acc[option[:currency]] = {unit_amount: (option[:amount].to_f * 100).to_i}
  #       acc
  #     end
  # end

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
        # user_id: product.user_id,
        product_id: painting.id
      },
      default_price_data: {
        # currency: params[:default_price_data][:currency],
        # unit_amount: (params[:default_price_data][:amount].to_f * 100).to_i,
        currency: painting.currency,
        unit_amount: painting.amount,
        # currency_options: currency_options
      },
      expand: ['default_price'],
    },)

    painting.update(
      stripe_id: stripe_product.id,
      data: stripe_product.to_json,
      stripe_price_id: stripe_product.default_price.id,
    )
  end

end
```

- created new product, got error
```
You may only specify one of these parameters: default_price_data, type.
```

#### upload attachments to aws
#### user gets a stripe customer id when they register
#### add admin to user, only they create paintings
#### you can only purchase if your signed in
#### the ability to buy images
#### the ability to download images via email or an order page where you can see all your orders



