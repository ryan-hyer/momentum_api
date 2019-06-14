require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        false,
    # target_username:        'KM_Admin',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
    target_groups:          %w(Mods),       # Mods GreatX BraveHearts
    instance:               'live',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:             %w()
}

schedule_options = {
    team_category_watching:   true,
    essential_watching:       true,
    growth_first_post:        true,
    meta_first_post:          true
}

discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary
