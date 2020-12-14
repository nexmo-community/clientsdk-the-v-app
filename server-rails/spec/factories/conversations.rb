FactoryBot.define do
  factory :conversation do
    vonage_id { "CON-" + SecureRandom.uuid }
    name { Faker::Name.first_name + "-" + SecureRandom.uuid }
    display_name { Faker::Name.name }
    state { "ACTIVE" }
    vonage_created_at { 5.minutes.ago }
  end
end
