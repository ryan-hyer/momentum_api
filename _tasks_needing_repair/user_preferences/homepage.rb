require '../utility/momentum_api'

@do_live_updates = false
client = connect_to_instance('live') # 'live' or 'local'

# testing variables
# @target_username = 'KM_Admin'
@issue_users = %w() # debug issue user_names

@user_option_targets = {
    'homepage_id': 2, #
    # 'email_direct': true,       # Send me an email when someone quotes me, replies to my post, mentions my @username, or invites me to a topic
}

@user_option_print = %w(
    last_seen_at
    last_posted_at
    post_count
    time_read
    recent_time_read
    homepage_id
)

@target_groups = %w(trust_level_0)
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin )
@field_settings = "%-18s %-14s %-16s %-12s %-12s %-17s %-14s\n"

zero_counters

def print_user_options(user_details)
  printf @field_settings, @users_username,
         user_details[@user_option_print[0].to_s].to_s[0..9], user_details[@user_option_print[1].to_s].to_s[0..9],
         user_details[@user_option_print[2].to_s], user_details[@user_option_print[3].to_s],
         user_details[@user_option_print[4].to_s], user_details['user_option'][@user_option_print[5].to_s]
end

# standardize_email_settings
def apply_function(user, admin_client, user_client='')  # TODO 1. update homepage_id
  @users_username = user['username']
  # @user_count += 1
  user_details = user_client.user(@users_username)
  user_groups = user_details['groups']
  user_option = user_details['user_option']

  user_groups.each do |group|
    @group_name = group['name']
    if @issue_users.include?(@users_username)
      puts "\n#{@users_username}  Group: #{@group_name}\n"
    end

    if @target_groups.include?(@group_name)
      # what to update
      value_setting_true = user_option[@user_option_targets.keys[0].to_s] == nil
      all_settings_true = [user_option[@user_option_targets.keys[0].to_s]].all?
      if not value_setting_true
        # puts 'All settings are correct'
        print_user_options(user_details)
      else
        # print_user_options(user_details)
        @user_targets += 1
        if @do_live_updates
          update_response = user_client.update_user(@users_username, @user_option_targets)
          puts update_response[:body]['success']
          @users_updated += 1

          # check if update happened
          user_details_after_update = user_client.user(@users_username)
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

apply_to_all_users(client)

# puts "\n#{@users_updated} users updated out of #{@user_targets} possible targets out of #{@user_count} total users."
scan_summary
