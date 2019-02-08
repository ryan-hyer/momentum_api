$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require File.expand_path('../../../lib/discourse_api', __FILE__)

# client = DiscourseApi::Client.new('https://discourse.gomomentum.org/')
# client.api_key = ENV['REMOTE_DISCOURSE_API']
client = DiscourseApi::Client.new('http://localhost:3000')
client.api_key = ENV['LOCAL_DISCOURSE_API']
client.api_username = 'KM_Admin'

# find groups
# @target = nil
@target_username = 'Kim_Miller'
@target_group_name = 'MadProps'

def member_notifications(client, user)
  puts "#{user['id']} #{user['name']}"
  @users_group_users = client.user(user['username'])['group_users']
  @users_groups = client.user(user['username'])['groups']
  @users_group_users.each do |users_group|
    @users_groups.each do |group|
      @user_group_id = users_group['group_id']
      @notification_level = users_group['notification_level']
      @default_level = group['default_notification_level']
      if group['id'] == @user_group_id and @notification_level != @default_level and group['id'] == 52
        @group_name = group['name']
        puts "Group ID:#{@user_group_id} #{@group_name}    Notification Level: #{@notification_level}    Default: #{@default_level}"
      end
    end
  end
end


retrieve_next = 1
while retrieve_next > 0
  @users = client.list_users('active', page: retrieve_next)
  if @users.empty?
    retrieve_next = 0
  else
    puts "Page .................. #{retrieve_next}"
    @users.each do |user|
      if @target_username
        if user['username'] == @target_username
          member_notifications(client, user)
        end
      else
        member_notifications(client, user)
        sleep(1)
      end
    end
    retrieve_next += 1
  end
end
