#!/usr/bin/env ruby

require_relative '../lib/momentum_api'

@scan_passes_end                =   -1

discourse_options = {
    do_live_updates:                false,
    debug_mode:                     true,
    # target_username:                'Laurence_Kuhn',     # Ryan_Hyer 2 Steve_Scott 9 Moe_Rubenzahl Kim_Miller David_Ashby KM_Admin
    target_groups:                  %w(trust_level_0),   # Mods GreatX BraveHearts trust_level_0 trust_level_1
    include_staged_users:           true,
    ownership_groups:               %w(Owner Owner_Manual),
    minutes_between_scans:          5,
    instance:                       'https://discourse.gomomentum.org',
    api_username:                   'KM_Admin',
    exclude_users:                  %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin MD_Admin),
    issue_users:                    %w(),
    log_file:                       File.expand_path('../logs/_run.log', __FILE__)
}

# schedule_options =                # manually set selected run options

@scan_passes                    =   0

@discourse = MomentumApi::Discourse.new(discourse_options)
# @discourse = MomentumApi::Discourse.new(discourse_options, schedule_options: schedule_options)

@discourse.options[:logger] = momentum_api_logger(@discourse.options[:log_file])
@discourse.options[:logger].info "Scanning #{@discourse.options[:target_groups]} Users for Tasks"

scan_hourly
@discourse.scan_summary
