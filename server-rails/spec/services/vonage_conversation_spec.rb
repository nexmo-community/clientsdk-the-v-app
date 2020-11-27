require "rails_helper"
require 'dotenv/load'
require 'faker'
require 'securerandom'

class VCR
  def self.load(file_path)
    path = Rails.root.join('spec', 'fixtures', file_path + '.json')
    # puts path
    if File.exist?(path)
      return File.read(path)
    end
  end
end

RSpec.describe VonageConversation do

  before(:each) do
    @vonage = VonageConversation.new()
  end


  it " - generates admin jwt" do
    jwt = @vonage.data_source.admin_jwt
    expect(jwt).to_not be_nil
  end
  
  describe "retrieve users" do

    it " - [LIVE]", :if => ENV['RUN_LIVE'] do
      users = @vonage.users
      expect(users.count).to be >= 0
    end

    it " - retrieve users" do
      allow(@vonage.data_source).to receive(:users).and_return(VCR.load('users/list_success'))
      users = @vonage.users
      # puts users
      expect(users).to_not be_nil
      expect(users.count).to be >= 0
    end

    it " - syncronising users" do
      user_1 = FactoryBot.create(:user, vonage_id: "USR-c25beea9-3b69-4583-a381-08d2e080eaae")
      expect(user_1.sync_at).to be <= 5.minutes.ago
      expect(User.all.count).to eq(1)
      allow(@vonage.data_source).to receive(:users).and_return(VCR.load('users/list_success'))
      expect(@vonage.users.count).to eq(5)
      expect(User.all.count).to eq(5)
      user_1.reload
      expect(user_1.name).to eq("Annice-3465f2ce-9bd5-4e3f-9a11-4de946ffd03b")
      expect(user_1.display_name).to eq("Donald McLaughlin")
      expect(user_1.sync_at).to be >= 10.seconds.ago
    end


    it " - error users - invalid response" do
      allow(@vonage.data_source).to receive(:users).and_return(nil)
      users = @vonage.users
      expect(users).to eq([])
    end
    it " - error users - empty string response" do
      allow(@vonage.data_source).to receive(:users).and_return("")
      users = @vonage.users
      expect(users).to eq([])
    end
    it " - error users - empty object response" do
      allow(@vonage.data_source).to receive(:users).and_return("{}")
      users = @vonage.users
      expect(users).to eq([])
    end
    it " - error users - invalid response - _embedded is not an object" do
      allow(@vonage.data_source).to receive(:users).and_return('{ "_embedded": "test"}')
      users = @vonage.users
      expect(users).to eq([])
    end
    it " - error users - invalid response - _embedded in an empty object" do
      allow(@vonage.data_source).to receive(:users).and_return('{ "_embedded": {}}')
      users = @vonage.users
      expect(users).to eq([])
    end
    it " - error users - invalid response - _embedded.users is not an object" do
      allow(@vonage.data_source).to receive(:users).and_return('{ "_embedded": {"users": "test"}}')
      users = @vonage.users
      expect(users).to eq([])
    end

  end

  describe ' create user ' do
    before(:all) do
      @name = Faker::Name.first_name + "-" + SecureRandom.uuid
      @display_name = Faker::Name.name
    end

    it " - [LIVE]", :if => ENV['RUN_LIVE'] do
      users = @vonage.users
      before_count = users.count
      @vonage.create_user(@name, @display_name)
      users = @vonage.users
      expect(users.count).to eq(before_count + 1)
    end

    it " - success" do
      allow(@vonage.data_source).to receive(:create_user).with(@name, @display_name).and_return(VCR.load('users/create_success'))
      user = @vonage.create_user(@name, @display_name)
      expect(user).to_not be_nil
      expect(user.id).to_not be_nil
      expect(user._links.self).to_not be_nil
    end
    it " - error: nil response" do
      allow(@vonage.data_source).to receive(:create_user).with(@name, @display_name).and_return(nil)
      user = @vonage.create_user(@name, @display_name)
      expect(user).to be_nil
    end
    it " - error: empty string response" do
      allow(@vonage.data_source).to receive(:create_user).with(@name, @display_name).and_return("")
      user = @vonage.create_user(@name, @display_name)
      expect(user).to be_nil
    end
    it " - error: empty object response" do
      allow(@vonage.data_source).to receive(:create_user).with(@name, @display_name).and_return("{}")
      user = @vonage.create_user(@name, @display_name)
      expect(user).to be_nil
    end
  end

  describe ' delete user' do
    before(:all) do
      @user_id = "USR-c25beea9-3b69-4583-a381-08d2e080eaae"
      @name = Faker::Name.first_name + "-" + SecureRandom.uuid
      @display_name = Faker::Name.name
    end

    it " - [LIVE] delete a user", :if => ENV['RUN_LIVE'] do
      @vonage.create_user(@name, @display_name)
      users = @vonage.users
      before_count = users.count
      expect(users.count).to be > 0
      user_id = users.first.id
      expect(user_id).to_not be_nil
      expect(@vonage.delete_user(user_id)).to be_truthy
      users = @vonage.users
      expect(users.count).to eq(before_count - 1)
    end

    it " - success" do
      allow(@vonage.data_source).to receive(:delete_user).with(@user_id).and_return(true)
      expect(@vonage.delete_user(@user_id)).to be_truthy
    end

    it " - error" do
      allow(@vonage.data_source).to receive(:delete_user).with(@user_id).and_return(false)
      expect(@vonage.delete_user(@user_id)).to be_falsy
    end

  end

end