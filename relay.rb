require 'eventmachine'
require 'em-http'
require 'json'

require 'flowdock'

$stdout.sync = true

token = ENV['FLOWDOCK_RELAY_USER_TOKEN']
organization = ENV['FLOWDOCK_RELAY_ORGANIZATION']
flows_to_relay = eval(ENV['FLOWDOCK_RELAY_FLOWS_TO_RELAY'])
target_flow_api_token = ENV['FLOWDOCK_RELAY_TARGET_FLOW_TOKEN']
get_users_from_flow_name = ENV['FLOWDOCK_RELAY_USERS_FLOW']

# -- get users

users = "https://api.flowdock.com/flows/#{organization}/#{get_users_from_flow_name}/users"

puts "Getting users.."

user_response = HTTParty.get(users,
  :basic_auth => {
    :username => token,
    :password => target_flow_api_token
  })

users_hash = {}

user_response.parsed_response.each do |user|
  users_hash[user["id"].to_s] = user["nick"]
end

puts "Got users:"
puts users_hash.inspect



threads = []

flows_to_relay.each do |flow_name|

  threads << Thread.new {

    http = EM::HttpRequest.new(
      "https://stream.flowdock.com/flows/#{organization}/#{flow_name}",
      :keepalive => true, :connect_timeout => 0, :inactivity_timeout => 0)

    EventMachine.run do
      s = http.get(:head => { 'Authorization' => [token, ''], 'accept' => 'application/json'})
      puts "Listening in #{flow_name}"

      buffer = ""
      s.stream do |chunk|
        buffer << chunk
        while line = buffer.slice!(/.+\r\n/)
          message = JSON.parse(line)

          if message["event"] == "message"
            formatted_message = "##{flow_name} #{message['content']}"
            user_name = users_hash[message['user']]
            flow = Flowdock::Flow.new(:api_token => target_flow_api_token, :external_user_name => user_name)
            flow.push_to_chat(:content => formatted_message)
            puts "#{user_name}: #{formatted_message}"
          end
        end
      end
    end
  }

end

while true do
  sleep 1
end