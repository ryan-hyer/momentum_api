require '../utility/momentum_api'

@do_live_updates = false
client = connect_to_instance('live') # 'live' or 'local'

# update to what notification_level?
# @target_category_slugs = %w(Essential)
# @target_notification_level = [3]
@target_category_slugs = %w(Growth routine meta)
@acceptable_notification_levels = [3, 4]
@set_notification_level = 4
@target_groups = %w(trust_level_0)
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin)

# testing variables
@target_username = 'Kim_Miller' # John_Oberstar Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
@issue_users = %w() # past in debug issue user_names

@user_count = 0
@matching_categories_count = 0
@users_updated = 0
@users_updated = 0


def apply_function(client, user)
  @starting_categories_updated = @users_updated
  @users_username = user['username']
  client.api_username = @admin_client
  @users_groups = client.user(@users_username)['groups']
  if @issue_users.include?(@users_username)
    puts @users_groups
  end

  client.api_username = @users_username                                   # Feb 21, 2019 Question pending
  @users_categories = client.categories

  @users_groups.each do |group|
    @group_name = group['name']
    if @issue_users.include?(@users_username)
      puts "\n#{@users_username}  Group: #{@group_name}\n"
    end
    if @target_groups.include?(@group_name)
      @users_categories.each do |category|
        @category_slug = category['slug']
        if @issue_users.include?(@users_username)
          puts "\n#{@users_username}  Category: #{@category_slug}\n"
        end
        if @target_category_slugs.include?(@category_slug)
          @users_category_notify_level = category['notification_level']
          if not @acceptable_notification_levels.include?(@users_category_notify_level)
            @category_id = category['id']
            printf "%-18s %-20s %-20s %-5s %-15s\n", @users_username, @group_name, @category_slug, @users_category_notify_level.to_s.center(5), 'NOT_Watching'

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
            if @issue_users.include?(@users_username)
              printf "%-18s %-20s %-20s %-5s\n", @users_username, @group_name, @category_slug, @users_category_notify_level.to_s.center(5)
            end
          end
          @matching_categories_count += 1
          sleep(1)
        end
      end
    end
  end
  if @users_updated > @starting_categories_updated
    @users_updated += 1
  end
end

printf "%-18s %-20s %-20s %-7s\n", 'UserName', 'Group', 'Category', 'Level'

apply_to_all_users(client)

puts "\n#{@matching_categories_count} matching Categories for #{@user_count} User found."
puts "\n#{@users_updated} Category notification_levels updated for #{@users_updated} Users."
