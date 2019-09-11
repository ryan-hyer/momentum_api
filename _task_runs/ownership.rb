require_relative 'log/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        true,
    target_username:        'Kim_Miller',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller David_Ashby Fernando_Venegas
    target_groups:          %w(trust_level_0),       # Mods GreatX BraveHearts trust_level_0 trust_level_1
    instance:               'https://staging.gomomentum.org',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:             %w(),
    logger:                  momentum_api_logger
}

schedule_options = {
    ownership:{
        # auto: {
        #     card_auto_renew_new_subscription_found: {
        #         do_task_update:         false,
        #         user_fields:            '6',
        #         ownership_code:         'CA',
        #         days_until_renews:      9999,
        #         action_sequence:        'R0',
        #         add_to_group:           nil,
        #         remove_from_group:      nil,
        #         message_to:             %w(Kim_Miller KM_Admin),
        #         message_from:           'Kim_Miller',
        #         subscrption_name:       'Owner Auto Renewing',
        #         excludes:               %w()
        #     },
        #     card_auto_renew_expires_next_week: {
        #         do_task_update:         false,
        #         user_fields:            '6',
        #         ownership_code:         'CA',
        #         days_until_renews:      7,
        #         action_sequence:        'R1',
        #         add_to_group:           nil,
        #         remove_from_group:      nil,
        #         message_from:           'Kim_Miller',
        #         subscrption_name:       'Owner Auto Renewing',
        #         excludes:               %w()
        #     },
        #     card_auto_renew_expired_yesterday: {
        #         do_task_update:         false,
        #         user_fields:            '6',
        #         ownership_code:         'CA',
        #         days_until_renews:      -1,
        #         action_sequence:        'R2',
        #         add_to_group:           nil,
        #         remove_from_group:      nil,
        #         message_from:           'Kim_Miller',
        #         excludes:               %w()
        #     },
        #     card_auto_renew_expired_last_week_final: {
        #         do_task_update:         false,
        #         user_fields:            '6',
        #         ownership_code:         'CA',
        #         days_until_renews:      -7,
        #         action_sequence:        'R3',
        #         add_to_group:           nil,
        #         remove_from_group:      nil,
        #         message_from:           'Kim_Miller',
        #         excludes:               %w()
        #     }
        # },
        manual: {
            zelle_new_found: {
                do_task_update:         false,
                user_fields:            '6',
                ownership_code:         'ZM',
                days_until_renews:      9999,
                action_sequence:        'R0',
                add_to_group:           'Owner_Manual',
                remove_from_group:      nil,
                message_to:             %w(Kim_Miller KM_Admin),
                message_from:           'Kim_Miller',
                excludes:               %w()
            },
            memberful_expires_next_week: {              # todo needs 3 Zelle expiring hash blocks
                                                        do_task_update:         false,
                                                        user_fields:            '6',
                                                        ownership_code:         'MM',
                                                        days_until_renews:      7,
                                                        action_sequence:        'R1',
                                                        add_to_group:           nil,
                                                        remove_from_group:      nil,
                                                        message_from:           'Kim_Miller',
                                                        excludes:               %w()
            },
            memberful_expired_today: {
                do_task_update:         false,
                user_fields:            '6',
                ownership_code:         'MM',
                days_until_renews:      0,
                action_sequence:        'R2',
                add_to_group:           nil,
                remove_from_group:      nil,
                message_from:           'Kim_Miller',
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
