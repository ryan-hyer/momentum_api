$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require File.expand_path('../../lib/discourse_api', __FILE__)

client = DiscourseApi::Client.new('http://localhost:3000')
client.api_key = ENV['LOCAL_DISCOURSE_API']
client.api_username = 'KM_Admin'

# find user
@user = client.user('Kim_Miller')
puts @user
# puts user.first
@user.each do |user|
  if user['name'] == 'Kim_Miller'
    puts user
  end
end
