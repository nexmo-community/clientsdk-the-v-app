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

end
