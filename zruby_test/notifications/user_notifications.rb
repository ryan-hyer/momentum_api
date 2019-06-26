require '../utility/momentum_api'

@do_live_updates = false

client = connect_to_instance('live')   # 'live' or 'local'
client.api_key = ENV['LOCAL_DISCOURSE_API']

client.api_username = 'Eric_Nitzberg'  # notification by this user

# find notifications
notifications = client.notifications['notifications']
notifications.each do |notification|
  puts notification['data']
end

