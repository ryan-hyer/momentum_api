$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require File.expand_path('../../lib/discourse_api', __FILE__)

client = DiscourseApi::Client.new("http://localhost:3000")
client.api_key = ENV['LOCAL_DISCOURSE_API']
client.api_username = 'KM_Admin'

# find groups
groups = client.groups['groups']

# puts groups.first
groups.each do |group|
  if group['name'] == 'MadProps'
    @group_id = group['id']
    puts @group_id
    @group_name = group['name']
    puts @group_name
    @members = client.group_members(@group_name)
    @members.each do |member|
      puts member['username']
      @users_group_users = client.user(member['username'])['group_users']
      @users_group_users.each do |check_ids|
        if check_ids['group_id'] == @group_id
          puts check_ids['notification_level']
          # puts check_ids['notification_level']
        end
      end
      # puts @users_groups
    end
  end
end
