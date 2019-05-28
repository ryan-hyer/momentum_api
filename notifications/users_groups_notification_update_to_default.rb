require '../lib/momentum_api'
require '../utility/momentum_api'

# $LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
# require File.expand_path('../lib/momentum_api/momentum_api', __FILE__)

# def user_group_notify_to_default(admin_client, group, user, user_details)
#   users_group_users = user_details['group_users']
#   users_group_users.each do |users_group|
#     if group['id'] == users_group['group_id']
#       if users_group['notification_level'] != group['default_notification_level'] # and if group['name'] == @target_group_name    # uncomment for just one group
#         printf "%-18s %-20s %-15s %-15s\n", user['username'], group['name'],
#                users_group['notification_level'].to_s.center(15), group['default_notification_level'].to_s.center(15)
#         @matching_categories_count += 1
#         if @do_live_updates
#           response = admin_client.group_set_user_notify_level(group['name'], user['id'], group['default_notification_level'])
#           sleep 1
#           puts response
#           @user_details_after_update = admin_client.user(user['username'])['group_users']
#           sleep 1
#           @user_details_after_update.each do |users_group_second_pass| # uncomment to check for the update
#             if users_group_second_pass['group_id'] == users_group['group_id']
#               puts "Updated Group: #{group['name']}    Notification Level: #{users_group_second_pass['notification_level']}    Default: #{group['default_notification_level']}"
#             end
#           end
#         end
#       else
#         # printf "%-16s %-20s %-15s %-15s  OK :)\n", user['username'], group['name'], notification_level.to_s.center(15), group['default_notification_level'].to_s.center(15)
#       end
#     end
#   end
# end

# def single_pass(client)

instance = 'live' # 'live' or 'local'

# testing variables
# @target_username = 'Kim_Miller' # Kim_test_Staged Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
# # @exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin
# #                           Joe_Sabolefski Steve_Scott Howard_Bailey)
zero_counters
# @user_count, @matching_category_notify_users, @matching_categories_count, @users_updated, @categories_updated,
#     @skipped_users = 0, 0, 0, 0, 0, 0

printf "%-18s %-18s %-15s %-15s\n", 'UserName', 'Group', "User's_Level", "Group's_Default"

def apply_function(master_client, user, user_client='')
  user_details = @admin_client.user(user['username'])
  sleep 1
  users_groups = user_details['groups']

  users_groups.each do |group|
    master_client.user_group_notify_to_default(group, user, user_details)
  end
end

# if @target_groups
#   @target_groups.each do |group_plug|
#     client.apply_to_group_users(group_plug, needs_user_client=true, skip_staged_user=true)
#   end
# else
#   client.apply_to_all_users(needs_user_client=true)
# end

# end

do_live_updates = false
target_username = 'Kim_Miller' # Kim_test_Staged Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
master_client = MomentumApi::Client.new('KM_Admin', instance, do_live_updates=do_live_updates,
                                        target_username=target_username)
# @exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin
#                           Joe_Sabolefski Steve_Scott Howard_Bailey)
master_client.apply_to_all_users(master_client, needs_user_client=true)

scan_summary

# if __FILE__ == $0
#
#   @do_live_updates = false
#   @instance = 'live' # 'live' or 'local'
#
#   # testing variables
#   @target_username = 'Kim_Miller' # Kim_test_Staged Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
#   # @exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin
#   #                           Joe_Sabolefski Steve_Scott Howard_Bailey)
#   zero_counters
#   # @user_count, @matching_category_notify_users, @matching_categories_count, @users_updated, @categories_updated,
#   #     @skipped_users = 0, 0, 0, 0, 0, 0
#
#   printf "%-18s %-18s %-15s %-15s\n", 'UserName', 'Group', "User's_Level", "Group's_Default"
#
#   @momentum_client = MomentumApi::Client.new('KM_Admin', @instance)
#   single_pass(@momentum_client)
#
#   # puts "#{@matching_categories_count} Notification Settings updated for #{@user_count} Users."
#   scan_summary
#
# end