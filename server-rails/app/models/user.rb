require 'openssl'
require 'jwt'

class User < ApplicationRecord

  has_secure_password(validations: false)

  validates :vonage_id, uniqueness: true
  validates :name, presence: { message: 'is required'}
  
  def active?
    is_active
  end

  def token
    expires_at = 30.minutes.from_now
    rsa_private = OpenSSL::PKey::RSA.new(ENV['VONAGE_APP_PRIVATE_KEY'])
    payload = {
      "application_id": ENV['VONAGE_APP_ID'],
      "sub": self.name,
      "exp": expires_at.to_i,
      "acl": '{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{}}}'
    }
    jwt = JWT.encode payload, rsa_private, 'RS256'
    return { jwt: jwt, expires_at: expires_at }
  end

  
end
