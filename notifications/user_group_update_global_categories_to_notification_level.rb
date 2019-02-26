$LOAD_PATH.unshift File.expand_path('../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../discourse_api/lib/discourse_api', __FILE__)

admin_client = 'KM_Admin'
starting_page_of_users = 1
client = DiscourseApi::Client.new('https://discourse.gomomentum.org/')
# client = DiscourseApi::Client.new('http://localhost:3000')
client.api_key = ENV['REMOTE_DISCOURSE_API']
# client.api_key = ENV['LOCAL_DISCOURSE_API']
client.api_username = admin_client

# update to what notification_level?
@target_notification_level = 3
@do_live_updates = false

# testing variables
@target_username = 'John_Oberstar'
# @target_username = nil

@issue_users = %w()

@user_count = 0
@matching_categories_count = 0
@users_updated = 0
@categories_updated = 0


def member_notifications(client, user)
  @starting_categories_updated = @categories_updated
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
          @category_id = category['id']
          # puts @category_id
          printf "%-18s %-20s %-20s %-8s %-15s\n", @users_username, @group_name, @category_slug, @users_category_notify_level.to_s.center(15), 'NOT_Watching'

          if @do_live_updates
            update_response = client.category_set_user_notification_level(@category_id, @target_notification_level)
            puts update_response
            @categories_updated += 1

            # check if update happened
            @users_categories_after_update = client.categories
            sleep(1)
            @users_categories_after_update.each do |users_category_second_pass| # uncomment to check for the update
              # puts "\nAll Category: #{users_category_second_pass['slug']}    Notification Level: #{users_category_second_pass['notification_level']}\n"
              if users_category_second_pass['slug'] == @group_name
                puts "Updated Category: #{@group_name}    Notification Level: #{users_category_second_pass['notification_level']}\n"
              end
            end
          end
        else
          if @issue_users.include?(@users_username)
            printf "%-18s %-20s %-20s %-5s\n", @users_username, @group_name, @category_slug, @users_category_notify_level.to_s.center(15)
          end
        end
        @matching_categories_count += 1
        sleep(1)
        break
      end
    end
  end
  if @categories_updated > @starting_categories_updated
    @users_updated += 1
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

puts "\n#{@matching_categories_count} matching Categories for #{@user_count} User found."
puts "\n#{@categories_updated} Category notification_levels updated for #{@users_updated} Users."