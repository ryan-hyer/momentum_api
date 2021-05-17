#!/usr/bin/env ruby

# require_relative 'log/ib/momentum_api/utility'
require_relative '../lib/momentum_api'

# @scan_passes_end                =   -1

discourse_options = {
    do_live_updates:                true,
    # target_username:                'Anthony_Martinez',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller David_Ashby KM_Admin
    target_groups:                  %w(trust_level_0),   # Mods GreatX BraveHearts trust_level_0 trust_level_1
    include_staged_users:           true,
    ownership_groups:               %w(Owner Owner_Manual),
    minutes_between_scans:          5,
    instance:                       'https://discourse.gomomentum.org',
    api_username:                   'KM_Admin',
    exclude_users:                  %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin MD_Admin),
    issue_users:                    %w(),
    logger:                         momentum_api_logger(File.expand_path('./logs/_run.log', __FILE__))
}

schedule_options = {
    # groups are 45: Onwers_Manual, 136: Owners (auto), 107: FormerOwners (expired)
    ownership:{
        settings: {
            all_ownership_group_ids: [45, 136]
        },
        auto: {
            card_auto_renew_new_subscription_found: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'CA',
                days_until_renews:      9999,
                action_sequence:        'R0',
                add_to_group:           nil,
                remove_from_group:      107,
                message_to:             nil,
                message_cc:             'KM_Admin,Mike_Drilling',
                message_from:           'Kim_Miller',
                subscrption_name:       'Owner Auto Renewing',
                excludes:               %w()
            },
            card_auto_renew_expires_next_week: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'CA',
                days_until_renews:      7,
                action_sequence:        'R1',
                add_to_group:           nil,
                remove_from_group:      nil,
                message_from:           'Kim_Miller',
                subscrption_name:       'Owner Auto Renewing',
                excludes:               %w()
            },
            card_auto_renew_expired_yesterday: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'CA',
                days_until_renews:      -1,
                action_sequence:        'R2',
                add_to_group:           nil,
                remove_from_group:      nil,
                message_from:           'Kim_Miller',
                excludes:               %w()
            },
            card_auto_renew_expired_last_week_final: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'CA',
                days_until_renews:      -7,
                action_sequence:        'R3',
                add_to_group:           107,
                remove_from_group:      136,
                message_cc:             'KM_Admin,Mike_Drilling',
                message_from:           'Kim_Miller',
                excludes:               %w()
            }
        },
        manual: {
            zelle_new_found: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'ZM',
                days_until_renews:      9999,
                action_sequence:        'R0',
                add_to_group:           45,
                remove_from_group:      107,
                message_to:             nil,
                message_cc:             'KM_Admin',
                message_from:           'Kim_Miller',
                excludes:               %w()
            },
            zelle_expires_next_week: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'ZM',
                days_until_renews:      7,
                action_sequence:        'R1',
                add_to_group:           nil,
                remove_from_group:      nil,
                message_from:           'Kim_Miller',
                excludes:               %w()
            },
            zelle_expired_today: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'ZM',
                days_until_renews:      0,
                action_sequence:        'R2',
                add_to_group:           nil,
                remove_from_group:      nil,
                message_from:           'Kim_Miller',
                excludes:               %w()
            },
            zelle_final: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'ZM',
                days_until_renews:      -7,
                add_to_group:           107,
                remove_from_group:      45,
                action_sequence:        'R3',
                message_cc:             'KM_Admin',
                message_from:           'Kim_Miller',
                excludes:                 %w()
            },
            new_user_found: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'NU',
                days_until_renews:      9999,
                action_sequence:        'R0',
                add_to_group:           108,
                # remove_from_group:      107,
                message_to:             nil,
                message_cc:             'KM_Admin',
                message_from:           'Kim_Miller',
                excludes:               %w()
            },
            new_user_one_week_ago: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'NU',
                days_until_renews:      -7,
                action_sequence:        'R1',
                add_to_group:           nil,
                remove_from_group:      nil,
                message_from:           'Kim_Miller',
                excludes:               %w()
            },
            new_user_two_weeks_ago: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'NU',
                days_until_renews:      -14,
                action_sequence:        'R2',
                add_to_group:           nil,
                remove_from_group:      nil,
                message_from:           'Kim_Miller',
                excludes:               %w()
            },
            new_user_three_weeks_ago: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'NU',
                days_until_renews:      -21,
                # add_to_group:           107,
                # remove_from_group:      45,
                action_sequence:        'R3',
                message_cc:             'KM_Admin',
                message_from:           'Kim_Miller',
                excludes:                 %w()
            }
        }
    },
    category:{
        matching_team:              {
            do_task_update:         true,
            allowed_levels:         [3],
            set_level:               3,
            excludes:               %w(Steve_Scott Ryan_Hyer David_Kirk)
        },
       Essential:                  {
            do_task_update:         true,
            allowed_levels:         [3],
            set_level:               3,
            excludes:               %w(Steve_Scott Joe_Sabolefski)
        },
        Growth:                     {
            do_task_update:         true,
            allowed_levels:         [3, 4],
            set_level:               4,
            excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott Suhas_Chelian)
        },
        Meta:                       {
            do_task_update:         true,
            allowed_levels:         [3, 4],
            set_level:               4,
            excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
        }
    },
    group:{
        group_alias:               {
            do_task_update:         true,
            allowed_levels:         nil,              # Default: 3
            set_level:              nil,              # Default: 3
            excludes:               %w()
        }
    },
    user:{
        preferences:                              {
            user_option: {
                email_messages_level: {
                    do_task_update:         true,
                    allowed_levels:         0,
                    set_level:              0,
                    excludes:               %w(Steve_Scott David_Kirk)
                }
            }
        },
        downgrade_non_owner_trust:                {
            do_task_update:         true,            # false = list but do not downgrade trust level
            allowed_levels:         0,                # Default: 0
            set_level:              0,                # Default: 0
            excludes:               %w()
        },
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
    },
    user_scores: {
        update_type:                'newly_voted',    # have_voted, not_voted, newly_voted, all
        target_post:                30719,            # 28707 28649
        # target_polls:             %w(poll),  # testing was version_two
        poll_url:                   'https://discourse.gomomentum.org/t/what-s-your-score/7104',
        messages_from:              'Kim_Miller',
        excludes:                   %w()
    }
}

# # init
# @scan_passes                    =   0
#
# def scan_hourly
#
#   begin
#     @discourse.counters[:'Processed Users'], @discourse.counters[:'Skipped Users'] = 0, 0
#     @discourse.apply_to_users
#     @scan_passes += 1
#
#     wait = @discourse.options[:minutes_between_scans] || 5
#     @discourse.options[:logger].info "Pass #{@scan_passes} complete for #{@discourse.counters[:'Processed Users']} users, #{@discourse.counters[:'Skipped Users']} skipped. Waiting #{wait} minutes ..."
#     @discourse.options[:logger].close
#     @discourse.options[:logger] = momentum_api_logger(File.expand_path('./logs/_run.log', __FILE__))
#     sleep wait * 60
#
#   rescue Exception => exception       # Recovers from any crash since Jul 22, 2019?
#     @discourse.options[:logger].warn "Scan Level Exception Rescue type #{exception.class}, #{exception.message}: Sleeping for 90 minutes ...."
#     sleep 90 * 60
#     scan_hourly
#   end
#
#   if @scan_passes < @scan_passes_end or @scan_passes_end < 0
#     scan_hourly
#     @discourse.options[:logger].info "... Exiting ..."
#   end
#
# end
#
# @discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
#
# @discourse.options[:logger].info "Scanning #{@discourse.options[:target_groups]} Users for Tasks"

discourse_options[:logger] = momentum_api_logger(discourse_options[:log_file])
discourse = MomentumApi::Discourse.new(discourse_options, schedule_options: schedule_options)
discourse.apply_to_users
discourse.scan_summary
