require_relative 'log/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        false,
    # target_username:        'Jerry_Strebig',     # David_Kirk Steve_Scott John_Butler Kim_Miller Jerry_Strebig Lee_Wheeler Brad_Peppard
    target_groups:          %w(trust_level_0),       # Mods GreatX BraveHearts trust_level_0 trust_level_1
    instance:               'https://discourse.gomomentum.org',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin MD_Admin),
    issue_users:             %w(),
    logger:                  momentum_api_logger
}

schedule_options = {
    user:{
        activity_groupping:                              {
            active_user: {
                do_task_update:         true,
                allowed_levels:          130,
                set_level:               130,
                excludes:               %w()
            },
            average_user: {
                do_task_update:         true,
                allowed_levels:          133,
                set_level:               133,
                excludes:               %w()
            },
            email_user: {
                do_task_update:         true,
                allowed_levels:          131,
                set_level:               131,
                excludes:               %w()
            },
            inactive_user: {
                do_task_update:         true,
                allowed_levels:          132,
                set_level:               132,
                excludes:               %w()
            }
        }
    }
}

discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary
