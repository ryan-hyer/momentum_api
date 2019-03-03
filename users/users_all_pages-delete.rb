require '../utility/momentum_api'

@do_live_updates = false
client = connect_to_instance('live') # 'live' or 'local'

starting_page_of_users = 1

# update to what notification_level?
# @target_category_slugs = %w(Essential)
@target_category_slugs = %w(Growth routine meta)
# @target_notification_level = [3]
@target_notification_level = [3, 4]
@set_notification_level = 4
@target_groups = %w(trust_level_0)
@do_live_updates = false 
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin)

# testing variables
@target_username = 'Marty_Fauth' # John_Oberstar Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
@issue_users = %w() # past in debug issue user_names

@user_count = 0
@user_feature_count = 0
@matching_categories_count = 0
@users_updated = 0
@users_updated = 0


def member_notifications(client, user)
  @starting_categories_updated = @users_updated
  @users_username = user['username']
  client.api_username = @admin_client
  @users_groups = client.user(@users_username)['groups']
  # if @issue_users.include?(@users_username)
  #   puts @users_groups
  # end

  # @users_categories = client.categories(api_username=@users_username)   # Feb 21, 2019 Question pending
  client.api_username = @users_username
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
          if not @target_notification_level.include?(@users_category_notify_level)
            @category_id = category['id']
            printf "%-18s %-20s %-20s %-5s %-15s\n", @users_username, @group_name, @category_slug, @users_category_notify_level.to_s.center(5), 'NOT_Watching'

            if @do_live_updates
              update_response = client.category_set_user_notification_level(@category_id, @set_notification_level)
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
          # break
        end
      end
    end
  end
  if @users_updated > @starting_categories_updated
    @users_updated += 1
  end
end

printf "%-18s %-20s %-20s %-7s\n", 'UserName', 'Mailing_List_Mode', '', ''
# printf "%-18s %-20s %-20s %-7s\n", 'UserName', 'Group', 'Category', 'Level'

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
      username = user['username']
      if @target_username
        if username == @target_username
          @user_count += 1
          # member_notifications(client, user)
        end
      elsif not @exclude_user_names.include?(username) and user['active'] == true
        user_details = client.user(username)
        user_mode = user_details['user_option']['mailing_list_mode']
        @user_count += 1
        sleep(2)
        if user_mode == true
          printf "%-18s %-20s %-20s %-7s\n", username, user_mode, '', ''
          @user_feature_count += 1
        end
        # puts user['username']
        # member_notifications(client, user)
        # sleep(2)  # really needs to be 3?
      end
    end
    starting_page_of_users += 1
  end
end

puts "\n#{@user_feature_count} mailing list mode users out of#{@user_count} Users found."
# puts "\n#{@matching_categories_count} matching Categories for #{@user_count} User found."
# puts "\n#{@categories_updated} Category notification_levels updated for #{@users_updated} Users."
