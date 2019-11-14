# require_relative 'log/ib/momentum_api/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        false,
    # target_username:        'Aneirin_Nunn',       # Vern_Mcgeorge David_Kirk Mitch_Slomiak Kim_Miller William_Burton
    target_groups:          %w(trust_level_0),  # Mods GreatX BraveHearts trust_level_0 trust_level_1 z_Legacy30 LaunchpadVI
    include_staged_users:   true,
    ownership_groups:        %w(Owner Owner_Manual),
    instance:               'https://discourse.gomomentum.org',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin MD_Admin),
    issue_users:             %w(),
    logger:                  momentum_api_logger

}

schedule_options =   {
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
            allowed_levels:         [3],
            # allowed_levels:         [3, 4],
            set_level:               3,
            # set_level:               4,
            excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
        },
        Meta:                       {
            do_task_update:         true,
            allowed_levels:         [3],
            # allowed_levels:         [3, 4],
            set_level:               3,
            # set_level:               4,
            excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
        },
        Routine:                       {
            do_task_update:         true,
            allowed_levels:         [3],
            # allowed_levels:         [3, 4],
            set_level:               3,
            # set_level:               4,
            excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
        }
    }
}

discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary
