$LOAD_PATH.unshift File.expand_path('../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../discourse_api/lib/discourse_api', __FILE__)

@admin_client = 'KM_Admin'
starting_page_of_users = 1
client = DiscourseApi::Client.new('https://discourse.gomomentum.org/')
# client = DiscourseApi::Client.new('http://localhost:3000')
client.api_key = ENV['REMOTE_DISCOURSE_API']
# client.api_key = ENV['LOCAL_DISCOURSE_API']
client.api_username = @admin_client

# update to what email setting?
@target_email_always = true
@target_email_direct = true
@target_email_private_messages = true
@target_email_digests = true

@target_groups = %w(trust_level_0)
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin)
@do_live_updates = true

# testing variables
@target_username = 'Eric_Nitzberg' # John_Oberstar Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
# @target_username = nil
@issue_users = %w() # past in debug issue user_names

@user_count = 0
@matching_categories_count = 0
@users_updated = 0
@users_updated = 0


def member_notifications(client, user)         # TODO run for all users, test mailing list mode
  @users_username = user['username']
  client.api_username = @admin_client
  user_details = client.user(@users_username)

  @users_groups = user_details['groups']
  @email_always = user_details['user_option']['email_always']
  @email_direct = user_details['user_option']['email_direct']
  @email_digests = user_details['user_option']['email_digests']
  @email_private_messages = user_details['user_option']['email_private_messages']
  @email_settings = [@email_always, @email_direct, @email_digests, @email_private_messages]

  @users_groups.each do |group|
    @group_name = group['name']
    if @issue_users.include?(@users_username)
      puts "\n#{@users_username}  Group: #{@group_name}\n"
    end

    if @target_groups.include?(@group_name)
      if @email_settings.all?
        # puts 'All settings are correct'
      else
        printf "%-18s %-20s %-6s %-6s %-6s %-6s\n", @users_username, @group_name, @email_always, @email_direct, @email_digests, @email_private_messages

        if @do_live_updates
          update_response = client.update_user(@users_username, email_always: true, email_direct: true, email_digests: true, email_private_messages: true)
          puts update_response[:body]['success']
          @users_updated += 1

          # check if update happened
          @user_details_after_update = client.user(@users_username)
          sleep(1)
          @email_always_after = @user_details_after_update['user_option']['email_always']
          @email_direct_after = @user_details_after_update['user_option']['email_direct']
          @email_digests_after = @user_details_after_update['user_option']['email_digests']
          @email_private_messages_after = @user_details_after_update['user_option']['email_private_messages']

          printf "Updated %-18s %-20s %-6s %-6s %-6s %-6s\n", @users_username, @group_name, @email_always_after, @email_direct_after, @email_digests_after, @email_private_messages_after
        end
      end
    end
    break
  end
end

printf "%-18s %-20s %-20s %-7s\n", 'UserName', 'Group', 'Category', 'Level'

while starting_page_of_users > 0
  # puts 'Top While'
  client.api_username = @admin_client
  # puts "client.api_username: #{client.api_username}\n"
  @users = client.list_users('active', page: starting_page_of_users)
  if @users.empty?
    starting_page_of_users = 0
  else
    # puts "Page .................. #{starting_page_of_users}"
    @users.each do |user|
      if @target_username
        if user['username'] == @target_username
          @user_count += 1
          member_notifications(client, user)
        end
      elsif not @exclude_user_names.include?(user['username']) and user['active'] == true
        @user_count += 1
        # puts user['username']
        member_notifications(client, user)
        sleep(2)  # really needs to be 3?
      end
    end
    starting_page_of_users += 1
  end
end

puts "\n#{@users_updated} users updated out of #{@user_count} users found."
