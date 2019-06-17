require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        false,
    target_username:        'KM_Admin',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller Don_Morgan KM_Admin
    target_groups:          %w(Mods),       # Mods GreatX BraveHearts
    instance:               'live',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin),
    # exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:             %w()
}

schedule_options = {
    score_user_levels: {
        update_type:    'newly_voted',      # have_voted, not_voted, newly_voted, all
        target_post:    30590,              # 28649
        # target_polls:   %w(poll),    # default is 'poll'
        poll_url:       'https://discourse.gomomentum.org/t/user-persona-survey/6485/20',
        messages_from:  'Kim_Miller'
    }
}

discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary
