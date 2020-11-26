class Vonage

  def self.balance
    uri = URI("https://rest.nexmo.com/account/get-balance?api_key=#{ENV['VONAGE_API_KEY']}&api_secret=#{ENV['VONAGE_API_SECRET']}")
    request = Net::HTTP::Get.new(uri)
    request['Content-type'] = 'application/json'
    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(request)
    }
    return nil unless response.is_a?(Net::HTTPSuccess)
    balance = JSON.parse(response.body, object_class: OpenStruct)
    return balance.value
  end

  def self.apps
    uri = URI('https://api.nexmo.com/v2/applications')
    request = Net::HTTP::Get.new(uri)
    auth = "Basic " + Base64.strict_encode64("#{ENV['VONAGE_API_KEY']}:#{ENV['VONAGE_API_SECRET']}")
    request['Authorization'] = auth
    request['Content-type'] = 'application/json'

    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(request)
    }
    return nil unless response.is_a?(Net::HTTPSuccess)
    json_object = JSON.parse(response.body, object_class: OpenStruct)
    return json_object._embedded.applications
  end


  def self.create_app(app_properties)
    uri = URI('https://api.nexmo.com/v2/applications/')
    request = Net::HTTP::Post.new(uri)
    auth = "Basic " + Base64.strict_encode64("#{ENV['VONAGE_API_KEY']}:#{ENV['VONAGE_API_SECRET']}")
    request['Authorization'] = auth
    request['Content-type'] = 'application/json'
    request.body = {
      name: app_properties[:name], 
      keys: {
        public_key: app_properties[:public_key]
      }, 
      capabilities: {
        voice: {
          webhooks: {
            answer_url: {
              address: app_properties[:voice_answer_url],
              http_method: app_properties[:voice_answer_method]
            },
            event_url: {
              address: app_properties[:voice_event_url],
              http_method: app_properties[:voice_event_method]
            }
          }
        },
        rtc: {
          webhooks: {
            event_url: {
              address: app_properties[:rtc_event_url],
              http_method: app_properties[:rtc_event_method]
            }
          }
        }
      }
    }.to_json
    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(request)
    }
    unless response.is_a?(Net::HTTPSuccess)
      puts "ERROR"
      puts response.body
      return false
    end

    jsonApp = JSON.parse(response.body, object_class: OpenStruct)
    return jsonApp
  end


  # def self.numbers(api_key, api_secret)
  #   uri = URI("https://rest.nexmo.com/account/numbers?api_key=#{api_key}&api_secret=#{api_secret}")
  #   request = Net::HTTP::Get.new(uri)
  #   request['Content-type'] = 'application/json'
  #   response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
  #     http.request(request)
  #   }
  #   return [] unless response.is_a?(Net::HTTPSuccess)
  #   json_object = JSON.parse(response.body, object_class: OpenStruct)
  #   return json_object.numbers
  # end


  # def self.number_search(api_key, api_secret, country)
  #   uri = URI("https://rest.nexmo.com/number/search?api_key=#{api_key}&api_secret=#{api_secret}&country=#{country}&features=VOICE&size=100")
  #   request = Net::HTTP::Get.new(uri)
  #   request['Content-type'] = 'application/json'
  #   response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
  #     http.request(request)
  #   }
  #   return nil unless response.is_a?(Net::HTTPSuccess)
  #   json_object = JSON.parse(response.body, object_class: OpenStruct)
  #   return json_object.numbers
  # end


  # def self.number_buy(api_key, api_secret, country, msisdn)
  #   uri = URI("https://rest.nexmo.com/number/buy?api_key=#{api_key}&api_secret=#{api_secret}")
  #   request = Net::HTTP::Post.new(uri)
  #   request.set_form_data({
  #     country: country,
  #     msisdn: msisdn
  #   })
  #   response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
  #     http.request(request)
  #   }
  #   return response.is_a?(Net::HTTPSuccess)
  # end


  # def self.number_link(api_key, api_secret, country, msisdn, app_id)
  #   uri = URI("https://rest.nexmo.com/number/update?api_key=#{api_key}&api_secret=#{api_secret}")
  #   request = Net::HTTP::Post.new(uri)
  #   properties = {
  #     country: country,
  #     msisdn: msisdn
  #   }
  #   unless app_id == nil 
  #     properties[:voiceCallbackType] = 'app'
  #     properties[:voiceCallbackValue] = app_id
  #   end
  #   request.set_form_data(properties)
  #   response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
  #     http.request(request)
  #   }
  #   return response.is_a?(Net::HTTPSuccess)
  # end


end
