$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require File.expand_path('../../lib/discourse_api', __FILE__)

client = DiscourseApi::Client.new('http://localhost:3000')
client.api_key = ENV['LOCAL_DISCOURSE_API']
client.api_username = 'KM_Admin'

# find users
@users = client.list_users('active', page:3)
@user_count = 0
@admin_count = 0

@users.each do |user|
  if not user['admin']
    puts user['username']
    @user_count += 1
  else
    @admin_count += 1
  end
end

puts "#{@user_count} Users"
puts "#{@admin_count} Admins"