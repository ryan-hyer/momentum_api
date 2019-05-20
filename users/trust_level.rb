require '../utility/momentum_api'

@do_live_updates = true

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
@exclude_groups = %w(Owner)  # MidPen, LaunchpadV, trust_level_0 DaVinci
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin Kim_Miller system discobot)
@field_settings = "%-18s %-14s %-16s %-12s %-12s %-17s %-14s\n"

@user_count, @user_targets, @users_updated = 0, 0, 0, 0

def print_user_options(user_details)
  printf @field_settings, user_details['username'],
         user_details[@user_option_print[0].to_s].to_s[0..9], user_details[@user_option_print[1].to_s].to_s[0..9],
         user_details[@user_option_print[2].to_s], user_details[@user_option_print[3].to_s],
         user_details[@user_option_print[4].to_s], user_details[@user_option_print[5].to_s]
end

# standardize_email_settings
def apply_function(client, user)
  users_username = user['username'] 
  # puts users_username, client.api_username
  @user_count += 1
  user_details = client.user(users_username)
  existing_trust_level = user_details[@user_preferences]
  user_groups = user_details['groups']
  is_owner = false

  user_groups.each do |group|
    group_name = group['name']
    if @issue_users.include?(users_username)
      puts "\n#{users_username}  Group: #{group_name}\n"
    end

    if @exclude_groups.include?(group_name)
      # puts "#{users_username} is in the #{group_name} group."
      is_owner = true
      break
    else
      is_owner = false
    end
  end

  if is_owner
    # puts 'Is owner 2nd check true'
  else
    # what to update
    if existing_trust_level == @user_preferences_targets
      # print_user_options(user_details)
      # puts 'User already correct'
    else
      print_user_options(user_details)
      # puts 'User to be updated'
      @user_targets += 1
      if @do_live_updates
        # update_response = client.update_user(users_username, {"#{@user_preferences}":@user_preferences_targets})
        update_response = client.update_trust_level(user_id: user['id'], level:@user_preferences_targets)
        puts "#{update_response['admin_user']['username']} Updated"
        @users_updated += 1

        # check if update happened
        user_details_after_update = client.user(users_username)
        print_user_options(user_details_after_update)
        sleep(1)
      end
    end
  end

end

printf @field_settings, 'UserName',
       @user_option_print[0], @user_option_print[1], @user_option_print[2],
       @user_option_print[3], @user_option_print[4], @user_option_print[5]

if @target_groups
  @target_groups.each do |group_plug|
    apply_to_group_users(group_plug, needs_user_client=false, skip_staged_user=false)
  end
else
  apply_to_all_users
end

puts "\n#{@users_updated} users updated out of #{@user_targets} possible targets out of #{@user_count} total users."

# May 20, 2019
# UserName           	last_seen_at   	last_posted_at   	post_count   	time_read    	recent_time_read  	trust_level
# John_Thompson      	2019-05-10     	2018-11-26       	91	94985	0	3
# Michael_Hayes      	2019-02-28     	2018-10-16       	16	3805	0	2
# Curt_Haynes        	2018-05-16     	2018-05-02       	17	3750	0	2
# Stephen_Gorman     	2017-07-19     	2019-05-11       	3	2507	0	2
# Steve_Lang         	2017-07-01     	2017-06-12       	41	35305	0	2
# Johnny_Alexander   	2017-05-13     	2017-08-05       	1	6022	0	2
