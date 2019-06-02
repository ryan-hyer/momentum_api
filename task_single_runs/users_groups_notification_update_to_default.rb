require '../lib/momentum_api'

do_live_updates = false

# testing variables
target_username = 'Tim_Tannatt' # Kim_test_Staged Randy_Horton Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
target_groups = %w(trust_level_1)  # Mods GreatX BraveHearts (trust_level_1 trust_level_0 hits 100 record limit)

master_client = MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates=do_live_updates,
                                           target_groups=target_groups, target_username=target_username)

scan_options = {
    user_group_alias_notify:  true
}

master_client.apply_to_users(scan_options)

master_client.scan_summary
