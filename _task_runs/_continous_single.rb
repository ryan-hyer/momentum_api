#!/usr/bin/env ruby

require_relative 'log/utility'
require_relative '../lib/momentum_api'

@scan_passes_end                =   -1

discourse_options = {
    do_live_updates:                false,
    # target_username:                'Kim_Miller',     # Ryan_Hyer 2 Steve_Scott 9 Moe_Rubenzahl Kim_Miller David_Ashby KM_Admin
    target_groups:                  %w(trust_level_0),   # Mods GreatX BraveHearts trust_level_0 trust_level_1
    include_staged_users:           true,
    minutes_between_scans:          0,
    instance:                       'https://discourse.gomomentum.org',
    api_username:                   'KM_Admin',
    exclude_users:                  %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin Scott_StGermain),
    issue_users:                    %w(Scott_StGermain),
    logger:                         momentum_api_logger
}

# groups are 45: Onwers_Manual, 136: Owners (auto), 107: FormerOwners (expired)
schedule_options = {
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
                message_cc:             'KM_Admin',
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
                message_cc:             'KM_Admin',
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
            memberful_expires_next_week: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'MM',
                days_until_renews:      7,
                action_sequence:        'R1',
                add_to_group:           nil,
                remove_from_group:      nil,
                message_cc:             'KM_Admin',
                message_from:           'Kim_Miller',
                excludes:               %w()
            },
            memberful_expired_today: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'MM',
                days_until_renews:      0,
                action_sequence:        'R2',
                add_to_group:           nil,
                remove_from_group:      nil,
                message_cc:             'KM_Admin',
                message_from:           'Kim_Miller',
                excludes:               %w()
            },
            memberful_final: {
                do_task_update:         true,
                user_fields:            '6',
                ownership_code:         'MM',
                days_until_renews:      -7,
                add_to_group:           107,
                remove_from_group:      45,
                action_sequence:        'R3',
                message_cc:             'KM_Admin',
                message_from:           'Kim_Miller',
                excludes:                 %w()
            }
        }
    }
}

# init
@scan_passes                    =   0

def scan_hourly

  begin
    @discourse.counters[:'Processed Users'], @discourse.counters[:'Skipped Users'] = 0, 0
    @discourse.apply_to_users
    @scan_passes += 1

    wait = @discourse.options[:minutes_between_scans] || 5
    @discourse.options[:logger].info "Pass #{@scan_passes} complete for #{@discourse.counters[:'Processed Users']} users, #{@discourse.counters[:'Skipped Users']} skipped. Waiting #{wait} minutes ..."
    @discourse.options[:logger].close
    @discourse.options[:logger] = momentum_api_logger
    sleep wait * 60

  rescue Exception => exception       # Recovers from any crash since Jul 22, 2019?
    @discourse.options[:logger].warn "Scan Level Exception Rescue type #{exception.class}, #{exception.message}: Sleeping for 90 minutes ...."
    sleep 90 * 60
    scan_hourly
  end

  if @scan_passes < @scan_passes_end or @scan_passes_end < 0
    scan_hourly
    @discourse.options[:logger].info "... Exiting ..."
  end

end

@discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)

@discourse.options[:logger].info "Scanning #{@discourse.options[:target_groups]} Users for Tasks"

scan_hourly
@discourse.scan_summary
