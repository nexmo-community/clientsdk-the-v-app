class User < ApplicationRecord

  has_secure_password(validations: false)

  validates :vonage_id, uniqueness: true
  validates :name, uniqueness: true, presence: { message: 'is required'}
  
  def active?
    is_active
  end
  
end
