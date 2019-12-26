# require_relative 'log/ib/momentum_api/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        true,
    target_username:          'Brad_Fino',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
    # target_groups:          %w(Mods),       # Mods GreatX BraveHearts trust_level_0
    ownership_groups:       %w(Owner Owner_Manual),
    instance:               'https://discourse.gomomentum.org',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin MD_Admin),
    issue_users:             %w(),
    logger:                         momentum_api_logger(File.expand_path('./logs/_run.log', __FILE__))
}

schedule_options = {
    user:{
        downgrade_non_owner_trust:                {
            do_task_update:         false,
            allowed_levels:         0,
            set_level:              0,
            excludes:               %w()
        }
    }
}

discourse_options[:logger] = momentum_api_logger(discourse_options[:log_file])
discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary
