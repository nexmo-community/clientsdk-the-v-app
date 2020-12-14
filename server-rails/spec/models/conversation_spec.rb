require 'rails_helper'

RSpec.describe Conversation, type: :model do
  context 'factories' do

    it '- has a valid factory' do 
      expect(FactoryBot.create(:conversation)).to be_valid
    end

  end

end
