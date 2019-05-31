require '../../lib/momentum_api'

def apply_function(master_client, user_details, user_client)
  master_client.user_poll.scan_users_score(master_client, user_client, user_details)
end

if __FILE__ == $0

  do_live_updates   = false
  instance          = 'live' # 'live' or 'local'

  # testing variables
  target_username   = nil # Kim_test_Staged Randy_Horton Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
  target_groups     = %w(Mods)  # Mods GreatX BraveHearts (trust_level_1 trust_level_0 hits 100 record limit)

  master_client     = MomentumApi::Client.new('KM_Admin', instance, do_live_updates=do_live_updates,
                                          target_groups=target_groups, target_username=target_username)

  scan_options = {
      score_user_levels: true
  }

  master_client.apply_to_users(scan_options)

  master_client.scan_summary

end
