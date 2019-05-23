require '../utility/momentum_api'


def set_category_notification(user, category, client, group_name, allowed_levels, set_level, do_live_updates=false)
  if not allowed_levels.include?(category['notification_level'])
    print_user(user, category, group_name, category['notification_level'])

    if do_live_updates
      update_response = client.category_set_user_notification(id: category['id'], notification_level: set_level)
      puts update_response
      @categories_updated += 1

      # check if update happened
      user_details_after_update = client.categories
      sleep(1)
      user_details_after_update.each do |users_category_second_pass| # uncomment to check for the update
        new_category_slug = users_category_second_pass['slug']
        if category['slug'] == new_category_slug
          puts "Updated Category: #{new_category_slug}    Notification Level: #{users_category_second_pass['notification_level']}\n"
        end
      end
    end
    @matching_category_notify_users += 1
  else
    if @issue_users.include?(user['username'])
      print_user(user, category, group_name, category['notification_level'])
    end
  end
  @matching_categories_count += 1
end

def global_category_to_watching

  def apply_function(user, admin_client, user_client=nil)
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
            set_category_notification(user, category, user_client, group_name, @acceptable_notification_levels,
                                      @set_notification_level, do_live_updates=@do_live_updates)
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

  # apply_to_all_users(needs_user_client=true)
  if @target_groups
    @target_groups.each do |group_plug|
      apply_to_group_users(group_plug, needs_user_client=true, skip_staged_user=true)
    end
  else
    apply_to_all_users(needs_user_client=true)
  end

end

if __FILE__ == $0

  def print_user(user, category, group_name, notify_level)
    field_settings = "%-18s %-20s %-20s %-10s %-15s\n"
    printf field_settings, 'UserName', 'Group', 'Category', 'Level', 'Status'
    printf field_settings, user['username'], group_name, category['slug'], notify_level.to_s.center(5), 'NOT_Watching'
  end

  @do_live_updates = false
  @instance = 'live' # 'live' or 'local'

  # update to what notification_level?
  @target_category_slugs = %w(Essential)          # Growth Routine Meta
  @acceptable_notification_levels = [3]           # [3] or [3 4]
  @set_notification_level = 3                     # 4 = Watching first post, 3 = Watching, 1 = blank or ...?
  @exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin
                            Joe_Sabolefski Steve_Scott Howard_Bailey)

  # testing variables
  # @target_username = 'Dennis_Adsit' # John_Oberstar Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
  @target_groups = %w(BraveHearts)  # BraveHearts trust_level_1 trust_level_0 hit 100 record limit.
  @issue_users = %w() # past in debug issue user_names

  @user_count, @matching_category_notify_users, @matching_categories_count, @users_updated, @categories_updated,
      @skipped_users = 0, 0, 0, 0, 0, 0

  global_category_to_watching
  
  field_settings = "%-35s %-20s \n"
  printf "\n"
  printf field_settings, 'Categories', ''
  printf field_settings, 'Categories Visible to Users: ', @matching_categories_count
  printf field_settings, 'Users Needing Update: ', @matching_category_notify_users
  printf field_settings, 'Users Skipped: ', @skipped_users
  printf field_settings, 'Updated Categories: ', @categories_updated
  printf field_settings, 'Updated Users: ', @users_updated
  printf field_settings, 'Total Users: ', @user_count

end
