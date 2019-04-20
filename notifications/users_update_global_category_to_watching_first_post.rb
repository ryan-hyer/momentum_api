require '../utility/momentum_api'

@do_live_updates = false
@instance = 'live' # 'live' or 'local'

# update to what notification_level?
@target_category_slugs = %w(Meta)
# @target_category_slugs = %w(Growth Routine Meta)
@acceptable_notification_levels = [3, 4]
@set_notification_level = 4   # 4 = Watching first post, 3 = Watching
# @target_groups = %w()  # must be a group the user can see. Most now cannot see trust_level_0
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin
                          Joe_Sabolefski Steve_Scott Howard_Bailey)

# testing variables
# @target_username = 'Dennis_Adsit' # John_Oberstar Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
@issue_users = %w() # past in debug issue user_names

@user_count = 0
@matching_user_count = 0
@matching_categories_count = 0
@users_updated = 0
@categories_updated = 0


def apply_function(client, user)
  @starting_categories_updated = @categories_updated
  @users_username = user['username']
  @users_groups = client.user(@users_username)['groups']
  if @issue_users.include?(@users_username)
    puts @users_groups
  end

  # client.api_username = @users_username                                   # Feb 21, 2019 Question pending
  @users_categories = client.categories

  @users_groups.each do |group|
    if @target_groups
      group_name = group['name']
      puts group_name
    else
      group_name = 'Any'
    end
    if @issue_users.include?(@users_username)
      puts "\n#{@users_username}  Group: #{group_name}\n"
    end

    if not @target_groups or @target_groups.include?(group_name)
      @users_categories.each do |category|
        @category_slug = category['slug']
        if @issue_users.include?(@users_username)
          puts "\n#{@users_username}  Category: #{@category_slug}\n"
        end
        if @target_category_slugs.include?(@category_slug)
          @users_category_notify_level = category['notification_level']
          if not @acceptable_notification_levels.include?(@users_category_notify_level)
            @category_id = category['id']
            printf "%-18s %-20s %-20s %-5s %-15s\n", @users_username, group_name, @category_slug, @users_category_notify_level.to_s.center(5), 'NOT_Watching'

            if @do_live_updates
              update_response = client.category_set_user_notification(id: @category_id, notification_level: @set_notification_level)
              puts update_response
              @categories_updated += 1

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
            @matching_user_count += 1
          else
            if @issue_users.include?(@users_username)
              printf "%-18s %-20s %-20s %-5s\n", @users_username, group_name, @category_slug, @users_category_notify_level.to_s.center(5)
            end
          end
          @matching_categories_count += 1
          sleep(2)
        end
      end
      break 
    end
  end
  @user_count += 1
  if @categories_updated > @starting_categories_updated
    @users_updated += 1
  end
end

printf "%-18s %-20s %-20s %-7s\n", 'UserName', 'Group', 'Category', 'Level'

apply_to_all_users(needs_user_client=true)

puts "\n#{@matching_categories_count} matching Categories for #{@matching_user_count} Users found out of #{@user_count} total."
puts "\n#{@categories_updated} Category notification_levels updated for #{@users_updated} Users."

# Apr 18, 2019

# UserName           Group                Category             Level
# Steve_Cross        Any                  Routine                1   NOT_Watching
# Steve_Scott        Any                  Growth                 1   NOT_Watching
# Steve_Scott        Any                  Routine                1   NOT_Watching
# Steve_Scott        Any                  Meta                   1   NOT_Watching
# David_Kirk         Any                  Growth                 1   NOT_Watching
# David_Kirk         Any                  Routine                1   NOT_Watching
# David_Kirk         Any                  Meta                   1   NOT_Watching
# Madon_Snell        Any                  Growth                 1   NOT_Watching
# Madon_Snell        Any                  Routine                1   NOT_Watching
# Madon_Snell        Any                  Meta                   1   NOT_Watching
# Suhas_Chelian      Any                  Growth                 1   NOT_Watching
# Suhas_Chelian      Any                  Routine                1   NOT_Watching
# Michael_Wilson     Any                  Growth                 1   NOT_Watching
# Michael_Wilson     Any                  Routine                1   NOT_Watching
# Michael_Wilson     Any                  Meta                   1   NOT_Watching
# Shane_Reed         Any                  Routine                1   NOT_Watching
# Shane_Reed         Any                  Meta                   1   NOT_Watching
# Janos_Keresztes    Any                  Growth                 1   NOT_Watching
# Janos_Keresztes    Any                  Routine                1   NOT_Watching
# Janos_Keresztes    Any                  Meta                   1   NOT_Watching
# Dennis_Adsit       Any                  Growth                 1   NOT_Watching
# Dennis_Adsit       Any                  Routine                1   NOT_Watching
# Dennis_Adsit       Any                  Meta                   1   NOT_Watching
# Howard_Bailey      Any                  Routine                1   NOT_Watching
# Howard_Bailey      Any                  Meta                   1   NOT_Watching
#
# 496 matching Categories for 0 User found.
#
# 0 Category notification_levels updated for 0 Users.