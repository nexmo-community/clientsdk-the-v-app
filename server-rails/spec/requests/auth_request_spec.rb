require 'rails_helper'

RSpec.describe "Auths", type: :request do

  describe "POST /signup" do
    before :each do
      @valid_attributes = {
        name: Faker::Name.first_name + "-" + SecureRandom.uuid,
        password: SecureRandom.uuid,
        display_name: Faker::Name.name
      }
    end

    it " - [LIVE]", :if => ENV['RUN_LIVE'] do
      expect(User.count).to eq(0)
      post signup_path, params: @valid_attributes
      expect(response).to have_http_status(200)
      user = User.last
      expect(user.name).to eq(@valid_attributes[:name])
      expect(user.display_name).to eq(@valid_attributes[:display_name])
    end

    context 'success' do

      it " - creates the user" do
        stub_request(:get, /api.nexmo.com/).to_return(body: "", status: 200)
        stub_request(:post, /api.nexmo.com/).to_return(body: VCR.load('users/create_success'), status: 200)
        expect {
          post signup_path, params: @valid_attributes
          expect(response).to have_http_status(200)
        }.to change { User.count }.by 1
        user = User.last
        expect(user.name).to eq("Annice-3465f2ce-9bd5-4e3f-9a11-4de946ffd03b")
        expect(user.display_name).to eq("Donald McLaughlin")
        expect(user.try(:authenticate, @valid_attributes[:password])).to be_truthy
      end


      it " - sets password for an existing user (not created via this API)" do
        stub_request(:get, /api.nexmo.com/).to_return(body: "", status: 200)
        stub_request(:post, /api.nexmo.com/).to_return(body: VCR.load('users/create_success'), status: 200)
        local_user = FactoryBot.create(:user, :no_password, vonage_id: "USR-c25beea9-3b69-4583-a381-08d2e080eaae", name: "Annice-3465f2ce-9bd5-4e3f-9a11-4de946ffd03b")
        expect {
          post signup_path, params: @valid_attributes.merge({name: "Annice-3465f2ce-9bd5-4e3f-9a11-4de946ffd03b"})
          expect(response).to have_http_status(200)
        }.to change { User.count }.by 0
        local_user.reload
        expect(local_user.display_name).to eq("Donald McLaughlin")
        expect(local_user.try(:authenticate, @valid_attributes[:password])).to be_truthy
      end

    
      it " - returns right response" do
        existing_user = FactoryBot.create(:user)
        stub_request(:any, /api.nexmo.com/).to_return(body: VCR.load('users/create_success'), status: 200)
        post signup_path, params: @valid_attributes
        expect(response).to have_http_status(200)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['user']['id']).to eq("USR-c25beea9-3b69-4583-a381-08d2e080eaae")
        expect(parsed_body['user']['name']).to eq("Annice-3465f2ce-9bd5-4e3f-9a11-4de946ffd03b")
        expect(parsed_body['user']['display_name']).to eq("Donald McLaughlin")
        expect(parsed_body['token']['jwt']).to_not be_nil
        expect(parsed_body['token']['expires_at']).to_not be_nil
        expect(parsed_body['users']).to_not be_nil
        expect(parsed_body['users'].count).to eq(1)
        expect(parsed_body['users'][0]['id']).to eq(existing_user.vonage_id)
        expect(parsed_body['users'][0]['name']).to eq(existing_user.name)
        expect(parsed_body['users'][0]['display_name']).to eq(existing_user.display_name)
        expect(parsed_body['conversations']).to_not be_nil
        expect(parsed_body['conversations'].count).to eq(0)
        # TODO - conversations
      end

    end

    context 'bad data' do
      before(:each) do
        stub_request(:any, /api.nexmo.com/).to_return(body: VCR.load('users/create_success'), status: 200)
      end
      it '- return error if no data' do
        expect {
          post signup_path
          expect(response).to have_http_status(400)
        }.to change {User.count}.by 0
      end
      it '- return error if no name' do
        expect {
          post signup_path, params: @valid_attributes.except(:name)
          expect(response).to have_http_status(400)
        }.to change {User.count}.by 0
      end
      it '- return error if no display_name' do
        expect {
          post signup_path, params: @valid_attributes.except(:display_name)
          expect(response).to have_http_status(400)
        }.to change {User.count}.by 0
      end

      it "- should not register user that already exists (and override password)"  do
        existing_user = FactoryBot.create(:user,
          vonage_id: "USR-c25beea9-3b69-4583-a381-08d2e080eaae",
          name: "Annice-3465f2ce-9bd5-4e3f-9a11-4de946ffd03b")
        expect(existing_user.password).to_not be_nil
        stub_request(:get, /api.nexmo.com/).to_return(body: VCR.load(''), status: 200)
        stub_request(:post, /api.nexmo.com/).to_return(body: VCR.load('users/create_success'), status: 200)
        expect {
          post signup_path, params: @valid_attributes.merge( { name: "Annice-3465f2ce-9bd5-4e3f-9a11-4de946ffd03b" })
          expect(response).to have_http_status(403)
        }.to change {User.count}.by 0
      end
    end
  end

  describe "POST /login" do
    before :each do
      @password = SecureRandom.uuid
      @user = FactoryBot.create(:user, 
        password: @password, 
        vonage_id: "USR-150d7f6e-3c65-4213-9fa6-a39ee8ef6090",
        name: "Asa-5ebfcafc-6c1f-4744-b74c-6cf5fc666aae"
      )
      @valid_attributes = { name: @user.name, password: @password }
    end

    context 'success' do

      it " - logs the user in" do
        expect {
          post login_path, params: @valid_attributes
          expect(response).to have_http_status(200)
        }.to change { User.count }.by 0
      end

      it " - returns right response" do
        existing_user = FactoryBot.create(:user)
        post login_path, params: @valid_attributes
        expect(response).to have_http_status(200)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['user']['id']).to eq(@user.vonage_id)
        expect(parsed_body['user']['name']).to eq(@user.name)
        expect(parsed_body['user']['display_name']).to eq(@user.display_name)
        expect(parsed_body['token']['jwt']).to_not be_nil
        expect(parsed_body['token']['expires_at']).to_not be_nil
        expect(parsed_body['users']).to_not be_nil
        expect(parsed_body['users'].count).to eq(1)
        expect(parsed_body['users'][0]['id']).to eq(existing_user.vonage_id)
        expect(parsed_body['users'][0]['name']).to eq(existing_user.name)
        expect(parsed_body['users'][0]['display_name']).to eq(existing_user.display_name)
        expect(parsed_body['conversations']).to_not be_nil
        expect(parsed_body['conversations'].count).to eq(0)
        # TODO - conversations
      end


    end

  end

end
