require 'rails_helper'

RSpec.describe "Webhooks", type: :request do

  describe "GET /rtc_events" do
    it "returns http success" do
      get "/webhook/rtc_events"
      expect(response).to have_http_status(:success)
    end
  end

end
