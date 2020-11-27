require 'rails_helper'

RSpec.describe User, type: :model do
  
  context 'factories' do

    it '- has a valid factory' do 
      expect(FactoryBot.create(:user)).to be_valid
    end

    it '- has a valid factory - no_password trait' do
      user = FactoryBot.create(:user, :no_password) 
      expect(user).to be_valid
      expect(user.password).to eq(nil)
    end

    it '- has a valid factory - inactive trait' do
      user = FactoryBot.create(:user, :inactive) 
      expect(user).to be_valid
      expect(user.is_active).to be_falsy
    end

    it '- has a valid factory - never_synced trait' do
      user = FactoryBot.create(:user, :never_synced) 
      expect(user).to be_valid
      expect(user.sync_at).to eq(nil)
    end

  end


end
