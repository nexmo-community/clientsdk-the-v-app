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

    it " - success" do
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
      api_users = @vonage.users
      expect(api_users.count).to eq(5)
      expect(User.all.count).to eq(5)
      user_1.reload
      expect(user_1.name).to eq("Annice-3465f2ce-9bd5-4e3f-9a11-4de946ffd03b")
      expect(user_1.display_name).to eq("Donald McLaughlin")
      expect(user_1.sync_at).to be >= 10.seconds.ago

      user_2 = User.find_by(vonage_id: 'USR-150d7f6e-3c65-4213-9fa6-a39ee8ef6090')
      expect(user_2).to_not be_nil
      expect(user_2.name).to eq("Asa-5ebfcafc-6c1f-4744-b74c-6cf5fc666aae")
      expect(user_2.display_name).to eq("Nakesha Price PhD")
      expect(user_2.sync_at).to be >= 10.seconds.ago
    end

    it " - error - invalid response" do
      allow(@vonage.data_source).to receive(:users).and_return(nil)
      users = @vonage.users
      expect(users).to eq([])
    end
    it " - error - empty string response" do
      allow(@vonage.data_source).to receive(:users).and_return("")
      users = @vonage.users
      expect(users).to eq([])
    end
    it " - error - empty object response" do
      allow(@vonage.data_source).to receive(:users).and_return("{}")
      users = @vonage.users
      expect(users).to eq([])
    end
    it " - error - invalid response - _embedded is not an object" do
      allow(@vonage.data_source).to receive(:users).and_return('{ "_embedded": "test"}')
      users = @vonage.users
      expect(users).to eq([])
    end
    it " - error - invalid response - _embedded in an empty object" do
      allow(@vonage.data_source).to receive(:users).and_return('{ "_embedded": {}}')
      users = @vonage.users
      expect(users).to eq([])
    end
    it " - error - invalid response - _embedded.users is not an object" do
      allow(@vonage.data_source).to receive(:users).and_return('{ "_embedded": {"users": "test"}}')
      users = @vonage.users
      expect(users).to eq([])
    end

  end

  describe ' create user ' do
    before(:each) do
      @name = Faker::Name.first_name + "-" + SecureRandom.uuid
      @display_name = Faker::Name.name
    end

    it " - [LIVE]", :if => ENV['RUN_LIVE'] do
      users = @vonage.users
      before_count = users.count
      new_user = @vonage.create_user(@name, @display_name)
      expect(new_user.vonage_id).to be_truthy
      expect(new_user.name).to eq(@name)
      expect(new_user.display_name).to eq(@display_name)
      users = @vonage.users
      expect(users.count).to eq(before_count + 1)
    end

    it " - success (new user)" do
      allow(@vonage.data_source).to receive(:create_user).with(@name, @display_name).and_return(VCR.load('users/create_success'))
      expect(User.all.count).to eq(0)
      user = @vonage.create_user(@name, @display_name)
      expect(user).to_not be_nil
      expect(user.vonage_id).to eq("USR-c25beea9-3b69-4583-a381-08d2e080eaae")
      expect(user.name).to eq("Annice-3465f2ce-9bd5-4e3f-9a11-4de946ffd03b")
      expect(user.display_name).to eq("Donald McLaughlin")
      expect(User.all.count).to eq(1)
    end
    it " - success (existing user)" do
      user_1 = FactoryBot.create(:user, vonage_id: "USR-c25beea9-3b69-4583-a381-08d2e080eaae")
      expect(user_1.sync_at).to be <= 5.minutes.ago
      expect(User.all.count).to eq(1)
      allow(@vonage.data_source).to receive(:create_user).with(@name, @display_name).and_return(VCR.load('users/create_success'))
      @vonage.create_user(@name, @display_name)
      expect(User.all.count).to eq(1)
      user_1.reload
      expect(user_1.vonage_id).to eq("USR-c25beea9-3b69-4583-a381-08d2e080eaae")
      expect(user_1.name).to eq("Annice-3465f2ce-9bd5-4e3f-9a11-4de946ffd03b")
      expect(user_1.display_name).to eq("Donald McLaughlin")
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
    it " - error: invalid object response - no id" do
      allow(@vonage.data_source).to receive(:create_user).with(@name, @display_name).and_return('{name: "test"}')
      user = @vonage.create_user(@name, @display_name)
      expect(user).to be_nil
    end
    it " - error: invalid object response - no name" do
      allow(@vonage.data_source).to receive(:create_user).with(@name, @display_name).and_return('{id: "test"}')
      user = @vonage.create_user(@name, @display_name)
      expect(user).to be_nil
    end
  end

  describe ' delete user' do
    before(:each) do
      @vonage_id = "USR-" + SecureRandom.uuid
      @name = Faker::Name.first_name + "-" + SecureRandom.uuid
      @display_name = Faker::Name.name
    end

    it " - [LIVE] delete a user", :if => ENV['RUN_LIVE'] do
      @vonage.create_user(@name, @display_name)
      users = @vonage.users
      before_count = users.count
      expect(before_count).to be > 0
      user = User.find_by(name: @name)
      expect(user).to_not be_nil
      expect(@vonage.delete_user(user.vonage_id)).to be_truthy
      users = @vonage.users
      expect(users.count).to eq(before_count - 1)
      after_deletion_user = User.find_by(name: @name)
      expect(after_deletion_user).to_not be_nil
      expect(after_deletion_user.is_active).to be_falsy
    end

    it " - success" do
      user = FactoryBot.create(:user, vonage_id: @vonage_id)
      expect(user).to be_active
      allow(@vonage.data_source).to receive(:delete_user).with(@vonage_id).and_return(true)
      after_deletion_user = @vonage.delete_user(@vonage_id)
      expect(after_deletion_user).to_not be_nil
      expect(after_deletion_user).to_not be_active
    end

    it " - error - no such user" do
      allow(@vonage.data_source).to receive(:delete_user).with(@vonage_id).and_return(true)
      expect(@vonage.delete_user(@vonage_id)).to eq(nil)
      allow(@vonage.data_source).to receive(:delete_user).with(@vonage_id).and_return(false)
      expect(@vonage.delete_user(@vonage_id)).to eq(nil)
    end

    it " - error - invalid response" do
      user = FactoryBot.create(:user, vonage_id: @vonage_id)
      expect(user).to be_active
      allow(@vonage.data_source).to receive(:delete_user).with(@vonage_id).and_return(false)
      after_deletion_user = @vonage.delete_user(@vonage_id)
      expect(after_deletion_user).to_not be_nil
      expect(after_deletion_user).to be_active
    end

  end

end