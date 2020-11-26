class User < ApplicationRecord

  has_secure_password

  validates :vonage_id, uniqueness: true
  validates :name, uniqueness: true, presence: { message: 'is required'}
  

end
