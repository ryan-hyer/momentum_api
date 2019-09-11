require_relative 'log/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        true,
    target_username:        'Bill_Heller',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller David_Ashby
    target_groups:          %w(trust_level_0),       # Mods GreatX BraveHearts trust_level_0 trust_level_1
    instance:               'https://discourse.gomomentum.org',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:             %w(),
    logger:                  momentum_api_logger
}

schedule_options = {
    user:{
        preferences:  {
            user_fields:                              {
                user_fields: {
                  do_task_update:         true,
                  allowed_levels:         '4/1/2019',
                  set_level:              {'6':'4/1/2019'},
                  excludes:               %w()
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

