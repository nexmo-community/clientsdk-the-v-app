require 'net/http'
require 'base64'
require 'json'
require 'ostruct'
require 'openssl'
require 'jwt'

class VonageConversationDataSource

  def admin_jwt
    rsa_private = OpenSSL::PKey::RSA.new(ENV['VONAGE_APP_PRIVATE_KEY'])
    payload = {
      "application_id": ENV['VONAGE_APP_ID'],
      "iat": Time.now.to_i,
      "jti": SecureRandom.uuid,
      "exp": (Time.now.to_i + 86400),
    }
    token = JWT.encode payload, rsa_private, 'RS256'
    return token
  end

  def users(url)
    uri = URI(url || 'https://api.nexmo.com/v0.3/users')
    request = Net::HTTP::Get.new(uri)
    auth = "Bearer " + admin_jwt
    request['Authorization'] = auth
    request['Content-type'] = 'application/json'

    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(request)
    }
    return response.is_a?(Net::HTTPSuccess) ? response.body : nil
  end

  def create_user(name, display_name)
    uri = URI('https://api.nexmo.com/v0.3/users')
    request = Net::HTTP::Post.new(uri)
    auth = "Bearer " + admin_jwt
    request['Authorization'] = auth
    request['Content-type'] = 'application/json'
    request.body = {name: name, display_name: display_name}.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(request)
    }
    return response.is_a?(Net::HTTPSuccess) ? response.body : nil
  end

  def delete_user(user_id)
    uri = URI('https://api.nexmo.com/v0.3/users/' + user_id)
    request = Net::HTTP::Delete.new(uri)
    auth = "Bearer " + admin_jwt
    request['Authorization'] = auth
    request['Content-type'] = 'application/json'

    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(request)
    }
    return response.is_a?(Net::HTTPSuccess)
  end
end




class VonageConversation
  def initialize
    @data_source = VonageConversationDataSource.new()
  end
  def data_source
    @data_source
  end

  def users(url = nil)
    response = @data_source.users(url)
    # puts response
    return [] if response == nil
    begin
      response_object = JSON.parse(response, object_class: OpenStruct)
    rescue JSON::ParserError
      return []
    end

    return [] if response_object._embedded == nil || 
      response_object._embedded.class.name != 'OpenStruct' ||
      response_object._embedded.users == nil || 
      response_object._embedded.users.class.name != 'Array'
    
    users = response_object._embedded.users

    if response_object._links != nil &&
      response_object._links.class.name == 'OpenStruct' &&
      response_object._links.next != nil &&
      response_object._links.next.class.name == 'OpenStruct' &&
      response_object._links.next.href != nil &&
      response_object._links.next.href.class.name == 'String'

      users += users(response_object._links.next.href)
    end

    users.each do |api_user|
      # vonage_id is the connection
      local_user = User.find_by(vonage_id: api_user.id)
      # if vonage_id
      if local_user != nil
        local_user.update(name: api_user.name, display_name: api_user.display_name, sync_at: DateTime.now)
        next
      end
      # if local user with name but no vonage_id
      local_user_with_name = User.find_by(name: api_user.name, vonage_id: nil)
      if local_user_with_name != nil
        local_user_with_name.update(vonage_id: api_user.id, display_name: api_user.display_name, sync_at: DateTime.now)
        next
      end
      # not a local user
      User.create!(vonage_id: api_user.id, name: api_user.name, display_name: api_user.display_name, sync_at: DateTime.now)
    end

    return User.all
  end


  def create_user(name, display_name)
    # TODO - this will fail if we try to create the same user twice (or users with same name)
    # - should check the local DB if it exists first
    # - this will also fail if the user is already created on the CAPI but not synced locally - should sync users first!
    response = @data_source.create_user(name, display_name)
    return nil if response == nil
    begin
      api_user = JSON.parse(response, object_class: OpenStruct)
    rescue JSON::ParserError
      return nil
    end
    return nil if api_user.id == nil || api_user.name == nil
    local_user = User.find_by(vonage_id: api_user.id)
    if local_user == nil 
      local_user = User.create(vonage_id: api_user.id, name: api_user.name, display_name: api_user.display_name, sync_at: DateTime.now)
    else
      local_user.update(name: api_user.name, display_name: api_user.display_name, sync_at: DateTime.now)
    end
    return local_user
  end


  def delete_user(user_id)
    user = User.find_by(vonage_id: user_id)
    if user != nil && @data_source.delete_user(user.vonage_id)
      user.update(is_active: false)
    end
    return user
  end


end