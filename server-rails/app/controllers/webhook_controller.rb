class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def rtc_events
    # "type": "conversation:created"
    # "application_id": "19e0465b-7cd9-4e7e-96d8-c7942a9bdb87",
    # puts request.raw_post
    begin
      json = JSON.parse(request.body.read)
    rescue JSON::ParserError
      render plain: 'Invalid JSON'
      return
    end
    
    if ENV['VONAGE_APP_ID'] != json['application_id']
      render plain: 'Wrong application'
      return
    end
    event_type = json["type"]
    event_body = json["body"]
    # check if not nil
    case event_type
    when "conversation:created"
      conversation = create_conversation(event_body)
      if conversation.blank?
        # record error
        render plain: 'Invalid conversation details'
        return
      end
    end
    render plain: 'ok'
    
  end

  
  private 
  def create_conversation(conversation_json)
    # "id": "CON-b273a8fc-c4f3-45bf-a059-139e925ce5d7",
    # "name": "NAM-ec666b5d-10f4-4b02-94a3-faf50e46e591",
    # "timestamp": {
    #     "created": "2020-12-14T14:35:24.457Z"
    # },
    # "display_name": "twitch 20201214-001",
    # "state": "ACTIVE"
    if conversation_json.empty? ||conversation_json["id"].empty? || conversation_json["name"].empty? || conversation_json["state"].empty? 
      return nil
    end
    conversation = Conversation.create(
      vonage_id: conversation_json["id"], 
      name: conversation_json["name"], 
      display_name: conversation_json["display_name"], 
      state: conversation_json["state"],
      vonage_created_at: conversation_json["timestamp"]["created"])

    return conversation
  end
end
