require '../utility/momentum_api'

@do_live_updates = false
client = connect_to_instance('live') # 'live' or 'local'

# update to what notification_level?
@acceptable_notification_levels = 3

# testing variables
# @target_username = 'Brad_Peppard'
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin Steve_Scott Ryan_Hyer
                           Kim_Miller David_Kirk)
@issue_users = %w()

@user_count, @matching_categories_count, @users_updated, @user_targets = 0, 0, 0, 0

# find and update member_notifications
def apply_function(client, user)
  @user_count += 1
  @starting_categories_updated = @users_updated
  @users_username = user['username']
  @users_groups = client.user(@users_username)['groups']

  client.api_username = @users_username # Feb 21, 2019 Question pending about setting api user
  @users_categories = client.categories
  sleep(1)
  
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
        # printf "%-18s %-20s %-20s %-8s %-15s\n", @users_username, @group_name, @category_slug, @users_category_notify_level.to_s.center(6), 'test_print'
        if @users_category_notify_level != 3
          @category_id = category['id']
          printf "%-18s %-20s %-20s %-8s %-15s\n", @users_username, @group_name, @category_slug, @users_category_notify_level.to_s.center(6), 'NOT_Watching'

          @user_targets += 1
          if @do_live_updates
            update_response = client.category_set_user_notification(id: @category_id, notification_level: @acceptable_notification_levels)
            puts update_response
            @users_updated += 1

            # check if update happened
            @user_details_after_update = client.categories
            sleep(1)
            @user_details_after_update.each do |users_category_second_pass| # uncomment to check for the update
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
  if @users_updated > @starting_categories_updated
    @users_updated += 1
  end
end

printf "%-18s %-20s %-20s %-5s\n", 'UserName', 'Group', 'Category', 'Level'

apply_to_all_users(client)

puts "\n#{@users_updated} users updated out of #{@user_targets} possible targets out of #{@user_count} total users with #{@matching_categories_count} matching Categories."

# Feb 28, 2019
# UserName           Group                Category             Level
# Steve_Scott        Foundry              Foundry                1      NOT_Watching
# Ryan_Hyer          ExpeditionProduction ExpeditionProduction   1      NOT_Watching
# Ryan_Hyer          InboundInquiry       InboundInquiry         1      NOT_Watching
#