$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require File.expand_path('../../../lib/discourse_api', __FILE__)

client = DiscourseApi::Client.new('http://localhost:3000')
client.api_key = ENV['LOCAL_DISCOURSE_API']
client.api_username = 'KM_Admin'

# find groups
groups = client.groups['groups']
# @target = nil
@target_username = 'MadProps'

@group_count = 0

def member_notifications(client, group)
  puts "#{group['id']} #{group['name']}"
  @members = client.group_members(group['name'])
  @members.each do |member|
    @users_group_users = client.user(member['username'])['group_users']
    @users_group_users.each do |check_ids|
      if check_ids['group_id'] == group['id']
        puts puts "#{check_ids['notification_level']} #{member['username']}"
      end
    end
  end
end


# puts groups.first
groups.each do |group|
  if @target_username
    if group['name'] == @target_username
        member_notifications(client, group)
    end
  else
    member_notifications(client, group)
    sleep(10)
  end
  puts group['name']
  @group_count += 1
end

puts "#{@group_count} User Groups"