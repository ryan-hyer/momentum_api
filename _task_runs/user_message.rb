require_relative 'log/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        true,
    target_username:        'Kim_Miller',         # David_Kirk Steve_Scott Scott_StGermain Kim_Miller David_Ashby Fernando_Venegas
    target_groups:          %w(trust_level_0),      # z_Legacy30 OpenKimono TechMods GreatX BraveHearts trust_level_0 trust_level_1
    instance:               'https://discourse.gomomentum.org',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:             %w(),
    logger:                  momentum_api_logger
}

# groups are 45: Onwers_Manual, 136: Owners (auto), 107: FormerOwners (expired)
schedule_options = {
    user:{
        messages:                              {
            message: {
                message_name:           'Legacy to Watching All',
                do_task_update:         true,
                action_sequence:        nil,
                add_to_group:           nil,
                remove_from_group:      nil,
                message_to:             nil,
                # message_cc:             'Kim_Miller',
                message_from:           'KM_Admin',
                message_file:           'z_Legacy30_190926',
                excludes:               %w()
            }
        },
    }
}

discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary
