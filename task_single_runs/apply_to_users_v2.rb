require '../lib/momentum_api'

if __FILE__ == $0

  scan_options = {
      team_category_watching: false,
      essential_watching: false,
      growth_first_post: false,
      meta_first_post: false,
      trust_level_updates: false,
      score_user_levels: true,
      user_group_alias_notify: false
  }

  # @emails_from_username     =   'Kim_Miller'

  do_live_updates           =   false
  instance                  =   'live' # 'live' or 'local'

  # testing variables
  target_username   = 'Kim_Miller' # Steven_Lang_Test Kim_test_Staged Randy_Horton Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
  target_groups     = %w(trust_level_1)  # OwnerExpired Mods GreatX BraveHearts trust_level_1 trust_level_0

  master_client = MomentumApi::Client.new('KM_Admin', instance, do_live_updates=do_live_updates,
                                          target_groups=target_groups, target_username=target_username)

  master_client.apply_to_users(scan_options)

  master_client.scan_summary

end
