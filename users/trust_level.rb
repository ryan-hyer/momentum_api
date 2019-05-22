require '../utility/momentum_api'

def update_trust_level(client, is_owner, trust_level_target, user, user_details)
  # puts 'update_trust_level'
  if @issue_users.include?(user['username'])
    puts "#{user['username']}  is_owner: #{is_owner}\n"
  end
  
  if is_owner
    # puts 'Is owner 2nd check true'
  else
    # what to update
    if user_details['trust_level'] == trust_level_target
      # print_user_options(user_details)
      # puts 'User already correct'
    else

      user_option_print = %w(
      last_seen_at
      last_posted_at
      post_count
      time_read
      recent_time_read
      trust_level
    )

      print_user_options(user_details, user_option_print)
      # puts 'User to be updated'
      @user_targets += 1
      if @do_live_updates
        update_response = client.update_trust_level(user_id: user['id'], level: trust_level_target)
        puts "#{update_response['admin_user']['username']} Updated"
        @users_updated += 1

        # check if update happened
        user_details_after_update = client.user(user['username'])
        print_user_options(user_details_after_update, user_option_print)
        sleep(1)
      end
    end
  end
end

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
  @exclude_groups = %w(Owner)  # MidPen, LaunchpadV, trust_level_0 DaVinci
  @exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin Kim_Miller system discobot)
  @field_settings = "%-18s %-14s %-16s %-12s %-12s %-17s %-14s\n"

  @user_count, @user_targets, @users_updated = 0, 0, 0, 0
  #
  # def print_user_options(user_details)
  #   printf @field_settings, 'UserName',
  #          @user_option_print[0], @user_option_print[1], @user_option_print[2],
  #          @user_option_print[3], @user_option_print[4], @user_option_print[5]
  #
  #   printf @field_settings, user_details['username'],
  #          user_details[@user_option_print[0].to_s].to_s[0..9], user_details[@user_option_print[1].to_s].to_s[0..9],
  #          user_details[@user_option_print[2].to_s], user_details[@user_option_print[3].to_s],
  #          user_details[@user_option_print[4].to_s], user_details[@user_option_print[5].to_s]
  # end

  # standardize_email_settings
  def apply_function(client, user)
    # users_username = user['username']
    # puts user['username'], client.api_username
    @user_count += 1
    user_details = client.user(user['username'])
    # existing_trust_level = user_details[@user_preferences]
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

    update_trust_level(client, is_owner, 0, user, user_details)

  end

  if @target_groups
    @target_groups.each do |group_plug|
      apply_to_group_users(group_plug, needs_user_client=false, skip_staged_user=false)
    end
  else
    apply_to_all_users
  end

end

# scan_trust_levels(do_live_updates=false)
# puts "\n#{@users_updated} users updated out of #{@user_targets} possible targets out of #{@user_count} total users."

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
