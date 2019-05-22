require '../utility/momentum_api'


def set_category_notification(user, category, client, group_name, allowed_levels, set_level)
    if not allowed_levels.include?(category['notification_level'])
      print_user(user, category, group_name, category['notification_level'])

      if @do_live_updates
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
      @matching_user_count += 1
    else
      if @issue_users.include?(user['username'])
        print_user(user, category, group_name, category['notification_level'])
      end
    end
    @matching_categories_count += 1
  # end
end

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

  @user_count = 0
  @matching_user_count = 0
  @matching_categories_count = 0
  @users_updated = 0
  @categories_updated = 0

  def apply_function(client, user)
    @starting_categories_updated = @categories_updated
    @users_username = user['username']
    @users_groups = client.user(@users_username)['groups']
    @users_categories = client.categories
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

          set_category_notification(category, client, group_name)

        end
        break
      end
    end
    @user_count += 1
    if @categories_updated > @starting_categories_updated
      @users_updated += 1
    end
  end

  apply_to_all_users(needs_user_client=true)

end

if __FILE__ == $0

  global_category_to_watching(do_live_updates=false , target_category_slugs=%w(Essential), acceptable_notification_levels=[3],
                              set_notification_level=3, exclude_user_names=%w())
  
  puts "\n#{@matching_categories_count} matching Categories for #{@matching_user_count} Users found out of #{@user_count} processed and #{@skipped_users} skipped."
  puts "\n#{@categories_updated} Category notification_levels updated for #{@users_updated} Users."

end
