require_relative 'log/utility'
require '../lib/momentum_api'
require 'csv'

discourse_options = {
    do_live_updates:        true,
    # target_username:        'Shane_Reed',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller David_Ashby Fernando_Venegas
    target_groups:          %w(trust_level_0),       # Tech Mods GreatX BraveHearts trust_level_0 trust_level_1
    ownership_groups:       %w(Owner Owner_Manual),
    instance:               'https://discourse.gomomentum.org',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin MD_Admin),
    issue_users:             %w(),
    logger:                  momentum_api_logger
}

lookup_file_path = "/Users/kimardenmiller/Dropbox/l_Spiritual/Momentum/Central/Discourse/Membership/Memberful_20190919_members_export_final_e.csv"
lookup_table = CSV.read(lookup_file_path, headers: true)

schedule_options = {
    user:{
        preferences:  {
            user_fields:                              {
                user_fields: {
                  do_task_update:         true,
                  allowed_levels:         '9999-99-99',
                  set_level:              {'6':lookup_table},
                  set_append:             ' MM R0',
                  excludes:               %w(Scott_StGermain)
              }
          }
        }
    }
}
discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary

# @user_preferences = 'user_fields'
# @user_fields_targets = {'5':'801'}    # user_fields[5] = Discourse User Score

# @user_option_print = %w(
#     last_seen_at
#     last_posted_at
#     post_count
#     time_read
#     recent_time_read
#     5
# )

