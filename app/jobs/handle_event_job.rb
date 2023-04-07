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
