require_relative 'log/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        false,
    target_username:        'Matthew_Raines',       # Tshombe_Moore David_Kirk Steve_Scott Kim_Miller Andrew_Webster
    target_groups:          %w(trust_level_0),  # Mods GreatX BraveHearts trust_level_0 trust_level_1
    include_staged_users:   true,
    instance:               'live',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:             %w(),
    logger:                  momentum_api_logger

}

schedule_options =   {
    category:{
        matching_team:              {
            allowed_levels:         [3],
            set_level:               3,
            excludes:               %w(Steve_Scott Ryan_Hyer David_Kirk)
        },
        essential:                  {
            allowed_levels:         [3],
            set_level:               3,
            excludes:               %w(Steve_Scott Joe_Sabolefski)
        },
        growth:                     {
            allowed_levels:         [3, 4],
            set_level:               4,
            excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
        },
        meta:                       {
            allowed_levels:         [3, 4],
            set_level:               4,
            excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
        }
    }
}

discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary
