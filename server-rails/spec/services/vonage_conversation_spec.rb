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

    it " - retrieve users" do
      allow(@vonage.data_source).to receive(:users).and_return(VCR.load('users/list_success'))
      users = @vonage.users
      # puts users
      expect(users).to_not be_nil
      expect(users.count).to be >= 0
      # expect(users._embedded.users).to_not be_nil
      # expect(users._links).to_not be_nil
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



  # it " - delete a user" do
  #   users = Vonage.users(ENV['APP_ID'], ENV['APP_PRIVATE_KEY'])
  #   before_count = users._embedded.users.count
  #   expect(users._embedded.users.count).to be > 0
  #   user_id = users._embedded.users.first.id
  #   expect(user_id).to_not be_nil
  #   expect(Vonage.delete_user(ENV['APP_ID'], ENV['APP_PRIVATE_KEY'], user_id)).to be_truthy
  #   users = Vonage.users(ENV['APP_ID'], ENV['APP_PRIVATE_KEY'])
  #   expect(users._embedded.users.count).to eq(before_count - 1)
  # end

end