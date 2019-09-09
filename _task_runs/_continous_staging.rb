#!/usr/bin/env ruby

require_relative 'log/utility'
require_relative '../lib/momentum_api'

@scan_passes_end                =   -1

discourse_options = {
    do_live_updates:                true,
    target_username:                'Kim_Miller',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller David_Ashby KM_Admin
    target_groups:                  %w(trust_level_0),   # Mods GreatX BraveHearts trust_level_0 trust_level_1
    include_staged_users:           true,
    minutes_between_scans:          0,
    instance:                       'staging',
    api_username:                   'KM_Admin',
    exclude_users:                  %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:                    %w(),
    logger:                         momentum_api_logger
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
                do_task_update:         true,
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
                do_task_update:         true,
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
