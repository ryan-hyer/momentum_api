module MomentumApi
  module Notification

    def set_category_notification(user, category, client, group_name, allowed_levels, set_level)

      def print_user(user_details, category, group_name, notify_level)
        field_settings = "%-18s %-20s %-20s %-10s %-15s\n"
        printf field_settings, 'UserName', 'Group', 'Category', 'Level', 'Status'
        printf field_settings, user_details['username'], group_name, category['slug'], notify_level.to_s.center(5), 'NOT_Watching'
      end

      if not allowed_levels.include?(category['notification_level'])
        print_user(user, category, group_name, category['notification_level'])

        if self.do_live_updates
          update_response = client.category_set_user_notification(id: category['id'], notification_level: set_level)
          sleep 1
          puts update_response
          @categories_updated += 1

          # check if update happened ... or ... comment out for no check after update
          user_details_after_update = client.categories
          sleep 1
          user_details_after_update.each do |users_category_second_pass|
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

    def user_group_notify_to_default(user_details)
      users_groups = user_details['groups']
      users_groups.each do |group|
        users_group_users = user_details['group_users']
        users_group_users.each do |users_group|
          if group['id'] == users_group['group_id']
            if users_group['notification_level'] != group['default_notification_level'] # and if group['name'] == @target_group_name    # uncomment for just one group
              field_settings = "%-18s %-18s %-15s %-15s\n"
              printf field_settings, 'UserName', 'Group', "User's_Level", "Group's_Default"
              printf field_settings, user_details['username'], group['name'],
                     users_group['notification_level'].to_s.center(15), group['default_notification_level'].to_s.center(15)
              @matching_categories_count += 1
              if self.do_live_updates
                response = @admin_client.group_set_user_notify_level(group['name'], user_details['id'], group['default_notification_level'])
                sleep 1
                puts response
                @user_details_after_update = @admin_client.user(user_details['username'])['group_users']
                sleep 1
                @user_details_after_update.each do |users_group_second_pass| # uncomment to check for the update
                  if users_group_second_pass['group_id'] == users_group['group_id']
                    puts "Updated Group: #{group['name']}    Notification Level: #{users_group_second_pass['notification_level']}    Default: #{group['default_notification_level']}"
                  end
                end
              end
            else
              # printf "%-16s %-20s %-15s %-15s  OK :)\n", user_details['username'], group['name'], users_group['notification_level'].to_s.center(15), group['default_notification_level'].to_s.center(15)
            end
          end
        end
      end
    end

  end
end
