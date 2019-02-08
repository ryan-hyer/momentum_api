$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require File.expand_path('../../lib/discourse_api', __FILE__)

client = DiscourseApi::Client.new("http://localhost:3000")
client.api_key = ENV['LOCAL_DISCOURSE_API']
client.api_username = 'KM_Admin'

# find notifications
notifications = client.notifications['notifications']
notifications.each do |notification|
  puts notification['data']
  # puts notification
end
# puts notifications['user_name']
# puts notifications.first
# notifications.each do |group|
# end
