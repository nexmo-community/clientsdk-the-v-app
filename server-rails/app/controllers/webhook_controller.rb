class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def rtc_events
    puts request.raw_post
    render plain: 'ok'
  end

end
