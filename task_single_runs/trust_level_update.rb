require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        false,
    # target_username:          'Brad_Fino',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
    target_groups:          %w(Mods),       # Mods GreatX BraveHearts trust_level_0
    instance:               'live',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:             %w()
}

schedule_options = {
    trust_level_updates:      true
}

discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary
