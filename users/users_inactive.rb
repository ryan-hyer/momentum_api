$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require File.expand_path('../../../lib/discourse_api', __FILE__)

client = DiscourseApi::Client.new('https://discourse.gomomentum.org/')
client.api_key = ENV['REMOTE_DISCOURSE_API']
# client = DiscourseApi::Client.new('http://localhost:3000')
# client.api_key = ENV['LOCAL_DISCOURSE_API']
client.api_username = 'KM_Admin'

# find users
@user_count = 0
@admin_count = 0
@user_list = []
@admin_list = []
users_whole = []

retrieve_next = 1
while retrieve_next > 0
  @users = client.list_users('active', page:retrieve_next)
  if @users.empty?
    retrieve_next = 0
  else
    @users.each do |user|
      users_whole << user
    end
    puts "Page .................. #{retrieve_next}  #{@users.length} users   #{users_whole.length} total"
    retrieve_next += 1
  end
end

@users_whole_sorted = users_whole.sort_by { |hash| hash['days_visited'] }
puts @users_whole_sorted.length
@users_whole_sorted.each do |user|
  @created = user['created_at'].to_s[0...10]
  @last_seen = user['last_seen_at'].to_s[0...10]
  @user = "#{user['username']}   Created: #{@created}   Last Seen: #{@last_seen}"
  if not user['admin']
    @user_list << @user
    @user_count += 1
  else
    @admin_list << @user
    @admin_count += 1
  end
end

puts @user_list
puts "#{@user_count} Users"
puts @admin_list
puts "#{@admin_count} Admins"
