require 'rails_helper'

RSpec.describe "Webhooks", type: :request do

  describe "GET /rtc/events" do
    
    it " - invalid application id" do
      post rtc_events_path, params: '{"application_id": "19e0465b-7cd9-4e7e-96d8-c7942a9bdb88"}', as: :json
      expect(response).to have_http_status(200)
    end
    
    context 'new conversation' do

      context 'success' do
        it " - returns success" do
          post rtc_events_path, params: VCR.load('webhooks/rtc_events/new_conversation'), headers: { 'Content-Type' => 'application/json' }
          expect(response).to have_http_status(200)
        end
        it " - creates a conversation in the DB" do
          expect {
            post rtc_events_path, params: VCR.load('webhooks/rtc_events/new_conversation'), headers: { 'Content-Type' => 'application/json' }
          }.to change { Conversation.count }.by 1
          new_conversation = Conversation.last
          expect(new_conversation.vonage_id).to eq("CON-b273a8fc-c4f3-45bf-a059-139e925ce5d7")
          expect(new_conversation.name).to eq("NAM-ec666b5d-10f4-4b02-94a3-faf50e46e591")
          expect(new_conversation.display_name).to eq("twitch 20201214-001")
          expect(new_conversation.state).to eq("ACTIVE")
          expect(new_conversation.vonage_created_at).to eq("2020-12-14T14:35:24.457Z")
        end

      end

      context 'error' do
        
        it " - invalid event type" do
          expect {
            post_json = VCR.load('webhooks/rtc_events/new_conversation')
            post rtc_events_path, params: post_json.sub('"type": "conversation:created"', '"type": "conversation:create"'), headers: { 'Content-Type' => 'application/json' }
          }.to change { Conversation.count }.by 0
        end

        it " - invalid body - empty" do
          expect {
            post rtc_events_path, params: '{
              "body": {
              },
              "application_id": "19e0465b-7cd9-4e7e-96d8-c7942a9bdb87",
              "timestamp": "2020-12-14T14:35:24.463Z",
              "type": "conversation:created"
            }', headers: { 'Content-Type' => 'application/json' }
          }.to change { Conversation.count }.by 0
        end

        it " - invalid body - invalid JSON" do
          expect {
            post rtc_events_path, params: 'asdfasdfasdasd'
          }.to_not change { Conversation.all.to_json }
        end
      end

    end


    context 'new member join' do

    end

  end

end
