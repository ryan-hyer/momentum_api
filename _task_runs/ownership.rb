require_relative 'log/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        true,
    target_username:        'Kim_Miller',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller David_Ashby Fernando_Venegas
    target_groups:          %w(trust_level_0),       # Mods GreatX BraveHearts trust_level_0 trust_level_1
    instance:               'staging',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:             %w(),
    logger:                  momentum_api_logger
}

schedule_options = {
    ownership:{
        manual: {
            memberful_expires_next_week: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'MM',
                days_until_renews:      7,
                action_sequence:        'R1',
                add_to_group:           nil,
                remove_from_group:      nil,
                message_from:           'Kim_Miller',
                flag_new:               true,
                excludes:               %w()
            },
           memberful_expires_today: {
                do_task_update:         false,
                user_fields:            '6',
                ownership_code:         'MM',
                days_until_renews:      0,
                action_sequence:        'R1',
                add_to_group:           nil,
                remove_from_group:      nil,
                message_from:           'Kim_Miller',
                flag_new:               true,
                excludes:               %w()
            },
            memberful_final: {
                do_task_update:         false,
                user_fields:            '6',
                ownership_code:         'MM',
                days_until_renews:      -7,
                add_to_group:           nil,
                remove_from_group:      'Owner_Manual',
                action_sequence:        'R3',
                message_from:           'Kim_Miller',
                excludes:                 %w()
            }
        }
    }
}

discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary
