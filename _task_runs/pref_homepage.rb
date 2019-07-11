require_relative 'log/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        true,
    target_username:        'Kim_Miller',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller David_Ashby
    target_groups:          %w(trust_level_1),       # Mods GreatX BraveHearts trust_level_1
    instance:               'live',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:             %w(),
    logger:                  momentum_api_logger
}

schedule_options = {
    user:{
        preferences:  {
            user_option: {
                homepage_id: {
                    do_task_update:         true ,
                    allowed_levels:         2,       # 2 is the Momentum standard
                    set_level:              2,
                    excludes:               %w()
                }
            }
        }
    }
}
discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary
