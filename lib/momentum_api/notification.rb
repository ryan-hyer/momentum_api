module MomentumApi
  module Notification

    def user_group_notify_to_default(group, user, user_details)
      users_group_users = user_details['group_users']
      users_group_users.each do |users_group|
        if group['id'] == users_group['group_id']
          if users_group['notification_level'] != group['default_notification_level'] # and if group['name'] == @target_group_name    # uncomment for just one group
            printf "%-18s %-20s %-15s %-15s\n", user['username'], group['name'],
                   users_group['notification_level'].to_s.center(15), group['default_notification_level'].to_s.center(15)
            @matching_categories_count += 1
            if @do_live_updates
              response = @admin_client.group_set_user_notify_level(group['name'], user['id'], group['default_notification_level'])
              sleep 1
              puts response
              @user_details_after_update = @admin_client.user(user['username'])['group_users']
              sleep 1
              @user_details_after_update.each do |users_group_second_pass| # uncomment to check for the update
                if users_group_second_pass['group_id'] == users_group['group_id']
                  puts "Updated Group: #{group['name']}    Notification Level: #{users_group_second_pass['notification_level']}    Default: #{group['default_notification_level']}"
                end
              end
            end
          else
            # printf "%-16s %-20s %-15s %-15s  OK :)\n", user['username'], group['name'], notification_level.to_s.center(15), group['default_notification_level'].to_s.center(15)
          end
        end
      end
    end


  end
end
