FactoryBot.define do
  factory :user do
    name { Faker::Name.first_name + "-" + SecureRandom.uuid }
    display_name { Faker::Name.name }
    password { SecureRandom.uuid }
    
    is_active { true }
    trait :inactive do
      is_active { false }
    end

    sync_at { 10.minutes.ago }
    trait :never_synced do
      sync_at { nil }
    end

  end
end
