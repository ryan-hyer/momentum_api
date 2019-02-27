$LOAD_PATH.unshift File.expand_path('../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../discourse_api/lib/discourse_api', __FILE__)

client = DiscourseApi::Client.new('https://discourse.gomomentum.org/')
client.api_key = ENV['REMOTE_DISCOURSE_API']
client.api_username = 'KM_Admin'
# client = DiscourseApi::Client.new('http://localhost:3000')
# client.api_key = ENV['LOCAL_DISCOURSE_API']

# testing variables
# @target_username = 'Kim_test_Staged'
@target_username = nil
@do_live_updates = false

@user_count = 0
@matching_categories_count = 0


def member_notifications(client, user)
  # puts "#{user['id']} #{user['name']}"
  @users_username = user['username']
  @users_groups = client.user(@users_username)['groups']

  @users_group_users = client.user(@users_username)['group_users']
  @users_group_users.each do |users_group|
    @user_group_id = users_group['group_id']
    @notification_level = users_group['notification_level']
    @users_groups.each do |group|
      if group['id'] == @user_group_id
        @group_name = group['name']
        @default_level = group['default_notification_level']
      end
    end
    if @notification_level != @default_level  # and if @group_name == @target_group_name    # uncomment for just one group
      printf "%-18s %-20s %-15s %-15s\n", @users_username, @group_name, @notification_level.to_s.center(15), @default_level.to_s.center(15)
      @matching_categories_count += 1
      if @do_live_updates
        response = client.group_set_user_notification_level(@group_name, user['id'], @default_level)
        puts response
        @user_details_after_update = client.user(@users_username)['group_users']
        @user_details_after_update.each do |users_group_second_pass| # uncomment to check for the update
          sleep(2)
          if users_group_second_pass['group_id'] == @user_group_id
            puts "Updated Group: #{@group_name}    Notification Level: #{users_group_second_pass['notification_level']}    Default: #{@default_level}"
          end
        end
      end
    else
      # printf "%-16s %-20s %-15s %-15s  OK :)\n", @users_username, @group_name, @notification_level.to_s.center(15), @default_level.to_s.center(15)
    end
  end
end


printf "%-18s %-18s %-15s %-15s\n", 'UserName', 'Group', "User's_Level", "Group's_Default"

retrieve_next = 1
while retrieve_next > 0
  @users = client.list_users('active', page: retrieve_next)
  if @users.empty?
    retrieve_next = 0
  else
    # puts "Page .................. #{retrieve_next}"
    @users.each do |user|
      if @target_username
        if user['username'] == @target_username
          @user_count += 1
          member_notifications(client, user)
        end
      else
        @user_count += 1
        member_notifications(client, user)
        sleep(2)
      end
    end
    retrieve_next += 1
  end
end

puts "#{@matching_categories_count} Notification Settings updated for #{@user_count} Users."