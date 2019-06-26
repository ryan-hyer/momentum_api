require '../utility/momentum_api'

@do_live_updates = true

@instance = 'live' # 'live' or 'local'

# testing variables
# @target_username = 'Moe_Rubenzahl'  # David_Ashby, Ryan_Hyer,
@issue_users = %w() # debug issue user_names

@user_option_targets = {
    'theme_ids': [10]
}

@user_option_print = %w(
    last_seen_at
    last_posted_at
    post_count
    time_read
    recent_time_read
    theme_ids
)

@target_groups = %w(DaVinci)  # MidPen, LaunchpadV, trust_level_0
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin )
@field_settings = "%-18s %-14s %-16s %-12s %-12s %-17s %-14s\n"

zero_counters

def print_user_options(user_details)
  printf @field_settings, user_details['username'],
         user_details[@user_option_print[0].to_s].to_s[0..9], user_details[@user_option_print[1].to_s].to_s[0..9],
         user_details[@user_option_print[2].to_s], user_details[@user_option_print[3].to_s],
         user_details[@user_option_print[4].to_s], user_details['user_option'][@user_option_print[5].to_s]
end

# standardize_email_settings
def apply_function(user, admin_client, user_client='')
  users_username = user['username']
  # puts users_username, client.api_username
  # @user_count += 1
  user_details = user_client.user(users_username)
  user_groups = user_details['groups']
  user_option = user_details['user_option']

  user_groups.each do |group|
    group_name = group['name']
    if @issue_users.include?(users_username)
      puts "\n#{users_username}  Group: #{group_name}\n"
    end

    if @target_groups.include?(group_name)
      # what to update
      existing_value = user_option[@user_option_targets.keys[0].to_s]
      # printf "Existing value: %-20s \n", existing_value
      target_value = @user_option_targets.values[0]
      # printf "Target value: %-20s \n",  target_value
      value_already_correct = existing_value == target_value
      # all_settings_true = [user_option[@user_option_targets.keys[0].to_s]].all?
      if value_already_correct
        # puts 'User already correct'
        # print_user_options(user_details)
      else
        puts 'User to be updated'
        print_user_options(user_details)
        @user_targets += 1
        if @do_live_updates
          update_response = user_client.update_user(users_username, @user_option_targets)
          puts update_response[:body]['success']
          @users_updated += 1

          # check if update happened
          user_details_after_update = user_client.user(users_username)
          print_user_options(user_details_after_update)
          sleep(1)
        end
      end
      break
    end
  end
end

printf @field_settings, 'UserName',
       @user_option_print[0], @user_option_print[1], @user_option_print[2],
       @user_option_print[3], @user_option_print[4], @user_option_print[5]

if @target_groups
  @target_groups.each do |group_plug|
    apply_to_group_users(group_plug, needs_user_client=false, skip_staged_user=true)
  end
else
  apply_to_all_users
end

# puts "\n#{@users_updated} users updated out of #{@user_targets} possible targets out of #{@user_count} total users."
scan_summary
