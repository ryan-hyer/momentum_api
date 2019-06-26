$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require File.expand_path('../../lib/discourse_api', __FILE__)

client = DiscourseApi::Client.new("http://localhost:3000")
client.api_key = ENV['LOCAL_DISCOURSE_API']
client.api_username = 'KM_Admin'

# find groups
groups = client.groups['groups']
# @target = 'MadProps'
@target_username = nil

# puts groups.first
groups.each do |group|
  if @target_username
    if group['name'] == 'MadProps'
      puts group
    end
  else
    puts "#{group['id']} #{group['name']}"
  end
end
