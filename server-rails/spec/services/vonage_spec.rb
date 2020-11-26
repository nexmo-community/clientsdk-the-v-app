require 'rails_helper'
require 'dotenv/load'


RSpec.describe Vonage do
  
  # it " - retrieved balance" do
  #   expect(ENV['VONAGE_API_KEY']).to_not be_nil
  #   expect(ENV['VONAGE_API_SECRET']).to_not be_nil
  #   balance = Vonage.balance
  #   puts balance
  #   expect(balance).to_not be_nil
  # end

  # it " - retrieved apps" do
  #   apps = Vonage.apps
  #   puts apps
  #   expect(apps).to_not be_nil
  #   expect(apps.count).to be >= 0
  # end

  # it " - creates an app" do
  #   app_properties = {
  #     name: Faker::App.name,
  #     public_key: '???',
  #     voice_answer_url: Faker::Internet.url,
  #     voice_answer_method: 'GET',
  #     voice_event_url: Faker::Internet.url,
  #     voice_event_method: 'POST',
  #     rtc_event_url: Faker::Internet.url,
  #     rtc_event_method: 'POST'
  #   }
  #   app = Vonage.create_app(app_properties)
  #   puts app
  #   expect(app).to_not be_nil
  #   expect(app.id).to_not be_nil
  #   expect(app.name).to eq(app_properties[:name])
  # end
end
