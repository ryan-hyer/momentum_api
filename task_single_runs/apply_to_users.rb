require '../lib/momentum_api'

do_live_updates           =   false

scan_options = {
    team_category_watching:   true,
    essential_watching:       true,
    growth_first_post:        true,
    meta_first_post:          true,
    trust_level_updates:      true,
    score_user_levels:        false,
    user_group_alias_notify:  false
}

# @emails_from_username     =   'Kim_Miller'

# testing variables
target_username   = 'David_Kirk' # Steven_Lang_Test Kim_test_Staged Randy_Horton Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
target_groups     = %w(trust_level_1)  # OwnerExpired Mods GreatX BraveHearts trust_level_1 trust_level_0

master_client = MomentumApi::Client.new('KM_Admin', 'live', do_live_updates=do_live_updates,
                                        target_groups=target_groups, target_username=target_username)

master_client.apply_to_users(scan_options)

master_client.scan_summary
