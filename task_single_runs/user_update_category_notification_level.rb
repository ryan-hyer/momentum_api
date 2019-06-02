require '../lib/momentum_api'

do_live_updates   = false
instance          = 'live' # 'live' or 'local'

# testing variables
target_username   = nil # Kim_test_Staged Randy_Horton Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
target_groups     = %w(trust_level_1)  # trust_level_1 Mods GreatX BraveHearts Alignment

master_client     = MomentumApi::Discourse.new('KM_Admin', instance, do_live_updates=do_live_updates,
                                               target_groups=target_groups, target_username=target_username)

scan_options = {
    team_category_watching:   true,
    essential_watching:       false,
    growth_first_post:        false,
    meta_first_post:          false,
}

master_client.apply_to_users(scan_options)

master_client.scan_summary

