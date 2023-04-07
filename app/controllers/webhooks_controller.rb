class WebhooksController < ApplicationController
	skip_before_action :verify_authenticity_token

	def create
		event = Event.create!(
			data: params,
			source: params[:source]
		)
		# logger.debug "This is event #{event}"
		HandleEventJob.perform_later(event)
		render json: { status: :ok }
	end
end
