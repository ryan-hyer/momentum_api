require '../lib/momentum_api'

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

  # poll parameters
  update_type       = 'not_voted'      # have_voted, not_voted, newly_voted, all
  target_post       = 28707            # 28649
  target_polls      = %w(version_two) # basic new version_two
  poll_url          = 'https://discourse.gomomentum.org/t/user-persona-survey/6485/20'

  user_score_poll   = MomentumApi::Poll.new(master_client, target_post, poll_url=poll_url, poll_names=target_polls, update_type=update_type)
  master_client.add_task(user_score_poll)

  scan_options = {
      score_user_levels: true
  }

  master_client.apply_to_users(scan_options)

  master_client.all_scores << user_score_poll.user_scores
  master_client.scan_summary

end
