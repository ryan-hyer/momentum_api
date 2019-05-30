require '../lib/momentum_api'
# require '../utility/momentum_api'

# set trust levels
def apply_function(master_client, user_details, user_client)
   @exclude_groups = %w(Owner)  # MidPen, LaunchpadV, trust_level_0 DaVinci
  user_groups = user_details['groups']
  is_owner = false

  user_groups.each do |group|
    group_name = group['name']
    if master_client.issue_users.include?(user_details['username'])
      puts "\n#{user_details['username']}  Group: #{group_name}\n"
    end

    if group_name == 'Owner'
      is_owner = true
      break
    end
  end

   master_client.update_user_trust_level(is_owner, 0, user_details)

end

do_live_updates = false
instance = 'live' # 'live' or 'local'

# testing variables
target_username = 'Brad_Fino' # Kim_test_Staged Brad_Fino Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
target_groups = %w(OwnerExpired)  # trust_level_0 Mods GreatX BraveHearts trust_level_1

master_client = MomentumApi::Client.new('KM_Admin', instance, do_live_updates=do_live_updates,
                                        target_groups=target_groups, target_username=target_username)

master_client.apply_to_users(method(:apply_function))
master_client.scan_summary


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
