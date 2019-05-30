require '../lib/momentum_api'
require '../utility/momentum_api'

# def update_trust_level(admin_client, is_owner, trust_level_target, user, user_details, do_live_updates=false)
#   # puts 'update_trust_level'
#   if @issue_users.include?(user['username'])
#     puts "#{user['username']}  is_owner: #{is_owner}\n"
#   end
#
#   if is_owner
#     # puts 'Is owner 2nd check true'
#   else
#     # what to update
#     if user_details['trust_level'] == trust_level_target
#       # puts 'User already correct'
#     else
#
#       user_option_print = %w(
#       last_seen_at
#       last_posted_at
#       post_count
#       time_read
#       recent_time_read
#       trust_level
#     )
#
#       print_user_options(user_details, user_option_print, 'Non Owner')
#       # puts 'User to be updated'
#       @user_targets += 1
#       if do_live_updates
#
#         update_response = admin_client.update_trust_level(user_id: user['id'], level: trust_level_target)
#         puts "#{update_response['admin_user']['username']} Updated"
#         @users_updated += 1
#
#         # check if update happened
#         user_details_after_update = admin_client.user(user['username'])
#         print_user_options(user_details_after_update, user_option_print, 'Non Owner')
#         sleep(1)
#       end
#     end
#   end
# end

def scan_trust_levels(do_live_updates=false)

  @do_live_updates = do_live_updates
  @instance = 'live' # 'live' or 'local'

  # testing variables
  # @target_username = 'John_Thompson'  # David_Ashby Ryan_Hyer Kim_Miller
  @issue_users = %w() # debug issue user_names

  @user_preferences = 'trust_level'
  @user_preferences_targets = 0

  @user_option_print = %w(
      last_seen_at
      last_posted_at
      post_count
      time_read
      recent_time_read
      trust_level
  )

  # @target_groups = %w(trust_level_1)  # LaunchpadV, trust_level_0 trust_level_1 ... needs apply_to_all_users
  @target_username = 'Brad_Fino' # John_Oberstar Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
  @exclude_groups = %w(Owner)  # MidPen, LaunchpadV, trust_level_0 DaVinci
  @exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin Kim_Miller system discobot)
  @field_settings = "%-18s %-14s %-16s %-12s %-12s %-17s %-14s\n"

  zero_counters

  # standardize_email_settings
  def apply_function(user, admin_client, user_client='')
    user_details = admin_client.user(user['username'])
    user_groups = user_details['groups']
    is_owner = false

    user_groups.each do |group|
      group_name = group['name']
      if @issue_users.include?(user['username'])
        puts "\n#{user['username']}  Group: #{group_name}\n"
      end

      if @exclude_groups.include?(group_name)
        # puts "#{user['username']} is in the #{group_name} group."
        is_owner = true
        break
      else
        is_owner = false
      end
    end

    update_trust_level(admin_client, is_owner, 0, user, user_details, do_live_updates=@do_live_updates)

  end

  if @target_groups
    @target_groups.each do |group_plug|
      apply_to_group_users(group_plug, needs_user_client=false, skip_staged_user=false)
    end
  else
    apply_to_all_users
  end

end

if __FILE__ == $0
  scan_trust_levels(do_live_updates=false)
end


# Updated May 20, 2019
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  trust_level
# Michael_Hayes      2019-02-28     2018-10-16       16           3805         0                 2
# Michael_Hayes Updated
# Michael_Hayes      2019-02-28     2018-10-16       16           3805         0                 0
# Curt_Haynes        2018-05-16     2018-05-02       17           3750         0                 2
# Curt_Haynes Updated
# Curt_Haynes        2018-05-16     2018-05-02       17           3750         0                 0
# Stephen_Gorman     2017-07-19     2019-05-11       3            2507         0                 2
# Stephen_Gorman Updated
# Stephen_Gorman     2017-07-19     2019-05-11       3            2507         0                 0
# Steve_Lang         2017-07-01     2017-06-12       41           35305        0                 2
# Steve_Lang Updated
# Steve_Lang         2017-07-01     2017-06-12       41           35305        0                 0
# Johnny_Alexander   2017-05-13     2017-08-05       1            6022         0                 2
# Johnny_Alexander Updated
# Johnny_Alexander   2017-05-13     2017-08-05       1            6022         0                 0
