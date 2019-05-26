require '../utility/momentum_api'

def global_category_to_watching(do_live_updates=false, target_category_slugs=nil, acceptable_notification_levels=[3, 4],
                                set_notification_level=4, exclude_user_names=%w() )

  @do_live_updates = do_live_updates
  @instance = 'live' # 'live' or 'local'

  # update to what notification_level?
  @target_category_slugs = target_category_slugs  # Growth Routine Meta
  @acceptable_notification_levels = acceptable_notification_levels
  @set_notification_level = 4   # 4 = Watching first post, 3 = Watching, 1 = blank or ...?
  @exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin
                            Joe_Sabolefski Steve_Scott Howard_Bailey)
  exclude_user_names.each do |exclude_user_name|
    @exclude_user_names << exclude_user_name
  end

  # testing variables
  # @target_username = 'Dennis_Adsit' # John_Oberstar Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
  # @target_groups = %w(BraveHearts)  # BraveHearts trust_level_1 trust_level_0 hit 100 record limit.
  @issue_users = %w() # past in debug issue user_names

  zero_counters
  # @user_count = 0
  # @matching_category_notify_users = 0
  # @matching_categories_count = 0
  # @users_updated = 0
  # @categories_updated = 0

  def print_user(group_name)
    field_settings = "%-18s %-20s %-20s %-10s %-15s\n"
    printf field_settings, 'UserName', 'Group', 'Category', 'Level', 'Status'
    printf field_settings, @users_username, group_name, @category_slug, @users_category_notify_level.to_s.center(5), 'NOT_Watching'
  end

  def apply_function(user, admin_client, user_client='')
    @starting_categories_updated = @categories_updated
    @users_username = user['username']
    @users_groups = user_client.user(@users_username)['groups']
    @users_categories = user_client.categories
    sleep(2)

    if @issue_users.include?(@users_username)
      puts @users_username
    end

    @users_groups.each do |group|
      if @target_groups
        group_name = group['name']
        # puts group_name
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
              print_user(group_name)

              if @do_live_updates
                update_response = user_client.category_set_user_notification(id: @category_id, notification_level: @set_notification_level)
                puts update_response
                @categories_updated += 1

                # check if update happened
                @user_details_after_update = user_client.categories
                sleep(1)
                @user_details_after_update.each do |users_category_second_pass| # uncomment to check for the update
                  @new_category_slug = users_category_second_pass['slug']
                  if @target_category_slugs.include?(@new_category_slug)
                    puts "Updated Category: #{@new_category_slug}    Notification Level: #{users_category_second_pass['notification_level']}\n"
                  end
                end
              end
              @matching_category_notify_users += 1
            else
              if @issue_users.include?(@users_username)
                print_user(group_name)
              end
            end
            @matching_categories_count += 1
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

  apply_to_all_users(needs_user_client = true)

end

if __FILE__ == $0

  global_category_to_watching(do_live_updates=false, target_category_slugs=%w(Meta), acceptable_notification_levels=[3, 4],
                              set_notification_level=4, exclude_user_names=%w(Bill_Herndon Michael_Wilson))
  
  puts "\n#{@matching_categories_count} matching Categories for #{@matching_category_notify_users} Users found out of #{@user_count} processed and #{@skipped_users} skipped."
  puts "\n#{@categories_updated} Category notification_levels updated for #{@users_updated} Users."

end

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