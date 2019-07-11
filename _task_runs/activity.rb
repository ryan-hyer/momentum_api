require_relative 'log/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        false,
    target_username:        'Kim_Miller',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller Jerry_Strebig Lee_Wheeler
    target_groups:          %w(trust_level_1),       # Mods GreatX BraveHearts trust_level_1
    instance:               'live',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:             %w(),
    logger:                  momentum_api_logger
}

schedule_options = {
    user:{
        activity:                              {
            recent_time_read: {
                do_task_update:         true,
                allowed_levels:         nil,
                set_level:              nil,
                excludes:               %w()
            },
            time_read: {
                do_task_update:         true,
                allowed_levels:         nil,
                set_level:              nil,
                excludes:               %w()
            },
            post_count: {
                do_task_update:         true,
                allowed_levels:         nil,
                set_level:              nil,
                excludes:               %w()
            }
        }
    }
}

discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary
