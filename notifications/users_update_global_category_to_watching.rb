require '../utility/momentum_api'

@do_live_updates = false
@instance = 'live' # 'live' or 'local'

# update to what notification_level?
@target_category_slugs = %w(Essential)
@acceptable_notification_levels = [3]
@set_notification_level = 3   # 4 = Watching first post, 3 = Watching
@target_groups = %w(LaunchpadV)  # must be a group the user can see. Most now cannot see trust_level_0
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin
                          Joe_Sabolefski Steve_Scott)

# testing variables
# @target_username = 'Kim_Miller' # Kim_Miller Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
@issue_users = %w() # past in debug issue user_names

@user_count = 0
@matching_categories_count = 0
@users_updated = 0
@users_updated = 0


def apply_function(client, user)
  @starting_categories_updated = @users_updated
  users_username = user['username']
  puts users_username
  # @users_groups = client.user(users_username)['groups']
  if @issue_users.include?(users_username)
    puts @users_groups
  end

  @users_categories = client.categories

  @users_categories.each do |category|
    @category_slug = category['slug']
    # puts @category_slug
    if @issue_users.include?(users_username)
      puts "\n#{users_username}  Category: #{@category_slug}\n"
    end
    if @target_category_slugs.include?(@category_slug)
      @users_category_notify_level = category['notification_level']
      if not @acceptable_notification_levels.include?(@users_category_notify_level)
        @category_id = category['id']
        printf "%-18s %-20s %-20s %-5s %-15s\n", users_username, group_name, @category_slug, @users_category_notify_level.to_s.center(5), 'NOT_Watching'

        if @do_live_updates
          update_response = client.category_set_user_notification(id: @category_id, notification_level: @set_notification_level)
          puts update_response
          @users_updated += 1

          # check if update happened
          @user_details_after_update = client.categories
          sleep(1)
          @user_details_after_update.each do |users_category_second_pass| # uncomment to check for the update
            # puts "\nAll Category: #{users_category_second_pass['slug']}    Notification Level: #{users_category_second_pass['notification_level']}\n"
            @new_category_slug = users_category_second_pass['slug']
            if @target_category_slugs.include?(@new_category_slug)
              puts "Updated Category: #{@new_category_slug}    Notification Level: #{users_category_second_pass['notification_level']}\n"
            end
          end
        end
      else
        if @issue_users.include?(users_username)
          printf "%-18s %-20s %-20s %-5s\n", users_username, group_name, @category_slug, @users_category_notify_level.to_s.center(5)
        end
        # printf "%-18s %-20s %-20s %-5s\n", users_username, group_name, @category_slug, @users_category_notify_level.to_s.center(5)
      end
      @matching_categories_count += 1
      # puts 'sleep 4'
      sleep(4)
    end
  end
  @user_count += 1
  if @users_updated > @starting_categories_updated
    @users_updated += 1
  end
end

printf "%-18s %-20s %-20s %-7s\n", 'UserName', 'Group', 'Category', 'Level'

if @target_groups
  @target_groups.each do |group_plug|
    apply_to_group_users(group_plug, needs_user_client=true, skip_staged_user=true)
  end
else  
  apply_to_all_users(needs_user_client=true)
end

puts "\n#{@matching_categories_count} matching Categories for #{@user_count} User found."
puts "\n#{@users_updated} Category notification_levels updated for #{@users_updated} Users."

# Apr 18, 2019   Users reset
#
# UserName           Group                Category             Level
# Dave_Lloyd         Any                  Essential              1   NOT_Watching
# Madon_Snell        Any                  Essential              1   NOT_Watching
# Suhas_Chelian      Any                  Essential              1   NOT_Watching
# Bill_Herndon       Any                  Essential              4   NOT_Watching
# Janos_Keresztes    Any                  Essential              1   NOT_Watching
