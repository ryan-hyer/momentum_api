$LOAD_PATH.unshift File.expand_path('../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../discourse_api/lib/discourse_api', __FILE__)

api_client_key = ENV['LOCAL_DISCOURSE_API']
print(api_client_key)
client = DiscourseApi::Client.new("http://localhost:3000")
client.api_key = api_client_key
client.api_username = 'KM_Admin'

# get latest topics
puts client.latest_topics
