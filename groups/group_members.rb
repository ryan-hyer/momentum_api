$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require File.expand_path('../../lib/discourse_api', __FILE__)

# api_client_key = ENV['LOCAL_DISCOURSE_API']
# print(api_client_key)
client = DiscourseApi::Client.new("http://localhost:3000")
client.api_key = ENV['LOCAL_DISCOURSE_API']
client.api_username = 'KM_Admin'

# get group members
mad_props_group = client.group_members('MadProps')

mad_props_group.each do |member|
  puts member['username']
end
# puts mad_props_group
