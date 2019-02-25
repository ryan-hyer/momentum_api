$LOAD_PATH.unshift File.expand_path('../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../discourse_api/lib/discourse_api', __FILE__)
# require File.expand_path('/Users/kimardenmiller/Dropbox/l_Spiritual/Momentum/discourse_api/lib/discourse_api', __FILE__)
# require '/Users/kimardenmiller/Dropbox/l_Spiritual/Momentum/discourse_api/lib/discourse_api'

admin_client = 'KM_Admin'
starting_page_of_users = 1
client = DiscourseApi::Client.new('https://discourse.gomomentum.org/')
# client = DiscourseApi::Client.new('http://localhost:3000')
client.api_key = ENV['REMOTE_DISCOURSE_API']
# client.api_key = ENV['LOCAL_DISCOURSE_API']
client.api_username = admin_client

# testing variables
# @target_username = 'Robbie_Bow'  # Peter_Sanchez
@target_username = nil
@do_live_updates = false

@issue_users = %w()
# @issue_users = %w(Robbie_Bow David_Nickerson Rich_Worthington Bo_Zhou Marton_Toth)

@user_count = 0
@matching_categories_count = 0


def member_notifications(client, user)
  @users_username = user['username']
  @users_groups = client.user(@users_username)['groups']

  # Feb 21, 2019 Question pending
  # @users_categories = client.categories(api_username=@users_username)
  client.api_username = @users_username
  @users_categories = client.categories

  @users_groups.each do |group|
    @group_name = group['name']
    if @issue_users.include?(@users_username)
      puts "\n#{@users_username}  Group: #{@group_name}\n"
    end
    @users_categories.each do |category|
      @category_slug = category['slug']
      if @issue_users.include?(@users_username)
        puts "\n#{@users_username}  Category: #{@category_slug}\n"
      end
      if @category_slug == @group_name
        @users_category_notify_level = category['notification_level']
        if @users_category_notify_level != 3
          printf "%-18s %-20s %-20s %-8s %-15s\n", @users_username, @group_name, @category_slug, @users_category_notify_level.to_s.center(15), 'NOT_Watching'
        else
          if @issue_users.include?(@users_username)
            printf "%-18s %-20s %-20s %-5s\n", @users_username, @group_name, @category_slug, @users_category_notify_level.to_s.center(15)
          end
        end
        @matching_categories_count += 1
        sleep(1)
        break
        # @group_name = @category_name
        # @default_level = category['default_notification_level']
      end
    end
    # if @notification_level != @default_level
    #   printf "%-16s %-20s %-15s %-15s\n", @users_username, @group_name, @notification_level.to_s.center(15), @default_level.to_s.center(15)
    #   if @do_live_updates
    #     response = client.group_set_user_notification_level(@group_name, user['id'], @default_level) # @default_level when final
    #     puts response
    #     @users_group_users_after_update = client.user(@users_username)['group_users']
    #     @users_group_users_after_update.each do |users_group_second_pass| # uncomment to check for the update
    #       sleep(2)
    #       if users_group_second_pass['group_id'] == @user_group_id
    #         puts "Updated Group: #{@group_name}    Notification Level: #{users_group_second_pass['notification_level']}    Default: #{@default_level}"
    #       end
    #     end
    #   end
    # else
    #   # printf "%-16s %-20s %-15s %-15s  OK :)\n", @users_username, @group_name, @notification_level.to_s.center(15), @default_level.to_s.center(15)
    # end
  end
end

printf "%-18s %-20s %-20s %-5s\n", 'UserName', 'Group', 'Category', 'Level'

while starting_page_of_users > 0
  # puts 'Top While'
  client.api_username = admin_client
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
      elsif not %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin).include?(user['username']) and user['active'] == true
        @user_count += 1
        # puts user['username']
        member_notifications(client, user)
        sleep(2)  # really needs to be 3?
      end
    end
    starting_page_of_users += 1
  end
end

puts "\n#{@matching_categories_count} matching Categories for #{@user_count} User's groups."