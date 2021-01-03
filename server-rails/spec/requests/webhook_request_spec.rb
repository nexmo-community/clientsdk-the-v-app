require 'rails_helper'

RSpec.describe "Webhooks", type: :request do

  describe "GET /rtc/events" do
    
    it " - invalid application id" do
      post rtc_events_path, params: '{"application_id": "19e0465b-7cd9-4e7e-96d8-c7942a9bdb88"}', as: :json
      expect(response).to have_http_status(418)
    end
    
    context 'new conversation' do

      context 'success' do
        it " - returns success" do
          post rtc_events_path, params: VCR.load('webhooks/rtc_events/new_conversation'), as: :json
          expect(response).to have_http_status(200)
        end
      end

      context 'error' do
        


        it " - invalid event type" do

        end

        it " - invalid body - empty" do
          
        end

        it " - invalid body - invalid JSON" do
          
        end
      end

    end


    context 'new member join' do

    end

  end

end
