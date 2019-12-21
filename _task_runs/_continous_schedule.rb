#!/usr/bin/env ruby

require_relative '../lib/momentum_api'

@scan_passes_end                =   -1

discourse_options = {
    do_live_updates:                true,
    # target_username:                'Kim_Miller',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller David_Ashby KM_Admin
    target_groups:                  %w(trust_level_0),   # Mods GreatX BraveHearts trust_level_0 trust_level_1
    include_staged_users:           true,
    ownership_groups:               %w(Owner Owner_Manual),
    minutes_between_scans:          5,
    instance:                       'https://discourse.gomomentum.org',
    api_username:                   'KM_Admin',
    exclude_users:                  %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin MD_Admin),
    issue_users:                    %w(),
    logger:                         momentum_api_logger
}

master_run_config = YAML.load_file File.expand_path('../_run_config.yml', __FILE__)
schedule_options =  master_run_config

@scan_passes                    =   0

@discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)

@discourse.options[:logger].info "Scanning #{@discourse.options[:target_groups]} Users for Tasks"

scan_hourly
@discourse.scan_summary
