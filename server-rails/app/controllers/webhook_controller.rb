class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def rtc_events
    
    # "type": "conversation:created"
    # "application_id": "19e0465b-7cd9-4e7e-96d8-c7942a9bdb87",
    # puts request.raw_post
    json = JSON.parse(request.body.read)
    byebug
    if ENV['VONAGE_APP_ID'] != json['application_id']
      render plain: 'Wrong application', status: 418
      return
    end
    render plain: 'ok'
    
  end

  
end
