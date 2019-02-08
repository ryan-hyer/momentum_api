$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require File.expand_path('../../lib/discourse_api', __FILE__)

client = DiscourseApi::Client.new("https://discourse.gomomentum.org")
client.api_key = ENV['REMOTE_DISCOURSE_API']
client.api_username = "KM_Admin"

# get latest topics
puts client.latest_topics
