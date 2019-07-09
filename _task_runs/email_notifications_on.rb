require_relative 'log/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        true,
    target_username:        'Kim_Miller',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller David_Ashby
    target_groups:          %w(trust_level_1),       # Mods GreatX BraveHearts trust_level_1
    instance:               'live',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:             %w(),
    logger:                  momentum_api_logger
}

schedule_options = {
    user:{
        preferences:                              {
            user_option: {
                email_messages_level: {
                    do_task_update:         true,
                    allowed_levels:         1,
                    set_level:              0,
                    excludes:               %w()
                }
            }
        }
    }
}
discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary


# Feb 27, 2019
#
# UserName           email_private_messages   email_direct   email_always                  mailing_list_mode
# Joe_Sabolefski     false                    false          false                         false
# OK
# Joe_Sabolefski     true                     true           true                          false
# John_Mansperger    true                     true           false                         false
# OK
# John_Mansperger    true                     true           true                          false
# Mark_Thorpe        true                     false          false                         false
# OK
# Mark_Thorpe        true                     true           true                          false
# Curt_Weil          true                     true           false                         true
# OK
# Curt_Weil          true                     true           true                          true
# Stefan_Schmitz     true                     true           false                         true
# OK
# Stefan_Schmitz     true                     true           true                          true
# John_Lasersohn     true                     true           false                         false
# OK
# John_Lasersohn     true                     true           true                          false
# Rich_Worthington   true                     true           false                         true
# OK
# Rich_Worthington   true                     true           true                          true
# Chris_Steck        true                     false          false                         false
# OK
# Chris_Steck        true                     true           true                          false
# Benjamin_Berman    true                     false          false                         false
# OK
# Benjamin_Berman    true                     true           true                          false
# Jeff_Cintas        true                     true           false                         true
# OK
# Jeff_Cintas        true                     true           true                          true
# Edmond_Cote        true                     true           false                         true
# OK
# Edmond_Cote        true                     true           true                          true
# Jack_McInerney     true                     false          false                         false
# OK
# Jack_McInerney     true                     true           true                          false
# Tom_Feasby         true                     true           false                         true
# OK
# Tom_Feasby         true                     true           true                          true
# Mitch_Slomiak      true                     true           false                         true
# OK
# Mitch_Slomiak      true                     true           true                          true
# Dan_Ollendorff     false                    false          false                         false
# OK
# Dan_Ollendorff     true                     true           true                          false
# Matthew_Lewsadder  true                     true           false                         false
# OK
# Matthew_Lewsadder  true                     true           true                          false
# Robbie_Bow         false                    false          false                         false
# OK
# Robbie_Bow         true                     true           true                          false
# Tony_Christopher   true                     true           false                         false
# OK
# Tony_Christopher   true                     true           true                          false
# Scott_StGermain    true                     true           false                         false
# OK
# Scott_StGermain    true                     true           true                          false
# Art_Muir           true                     true           false                         false
# OK
# Art_Muir           true                     true           true                          false
# EO_Rojas           true                     true           false                         false
# OK
# EO_Rojas           true                     true           true                          false
# Barry_Finkelstein  true                     false          false                         false
# OK
# Barry_Finkelstein  true                     true           true                          false
# John_Jeffs         true                     false          true                          false
# OK
# John_Jeffs         true                     true           true                          false
# Chris_Reed         true                     true           false                         false
# OK
# Chris_Reed         true                     true           true                          false
# Don_Morgan         true                     true           false                         false
# OK
# Don_Morgan         true                     true           true                          false
# Geoff_Wright       true                     true           false                         false
# OK
# Geoff_Wright       true                     true           true                          false
# Brad_Peppard       true                     true           false                         true
# OK
# Brad_Peppard       true                     true           true                          true
# Tonio_Schutze      false                    false          false                         false
# OK
# Tonio_Schutze      true                     true           true                          false
# Ken_Krantz         true                     false          false                         false
# OK
# Ken_Krantz         true                     true           true                          false
# Michael_Hayes      false                    false          false                         false
# OK
# Michael_Hayes      true                     true           true                          false
# Dave_Mussoff       true                     true           false                         false
# OK
# Dave_Mussoff       true                     true           true                          false
# Narjit_Chadha      false                    false          false                         false
# OK
# Narjit_Chadha      true                     true           true                          false
# Barry_Dobyns       true                     true           false                         false
# OK
# Barry_Dobyns       true                     true           true                          false
# Peter_Montana      false                    false          false                         false
# OK
# Peter_Montana      true                     true           true                          false
# Kevin_Shutta       false                    false          false                         false
# OK
# Kevin_Shutta       true                     true           true                          false
# Alan_Schoen        false                    false          false                         false
# OK
# Alan_Schoen        true                     true           true                          false
# Jim_LoConte        false                    false          false                         false
# OK
# Jim_LoConte        true                     true           true                          false
# Aaron_Jenkins      false                    false          false                         false
# OK
# Aaron_Jenkins      true                     true           true                          false
# Ravi_Narra         true                     true           false                         true
# OK
# Ravi_Narra         true                     true           true                          true
# Lars_Rider         true                     true           false                         true
# OK
# Lars_Rider         true                     true           true                          true
# Greg_Thayer        false                    false          false                         false
# OK
# Greg_Thayer        true                     true           true                          false
# John_Piggott       true                     true           false                         false
# OK
# John_Piggott       true                     true           true                          false
# Ken_Hartman        false                    false          false                         false
# OK
# Ken_Hartman        true                     true           true                          false
# Toby_Ward          false                    false          false                         false
# OK
# Toby_Ward          true                     true           true                          false
# Johnny_Alexander   false                    false          false                         false
# OK
# Johnny_Alexander   true                     true           true                          false
# Praveen_Rangu      true                     true           false                         false
# OK
# Praveen_Rangu      true                     true           true                          false
# Jason_Heimann      false                    false          false                         false
# OK
# Jason_Heimann      true                     true           true                          false
# Nicolas_Ardelean   false                    false          false                         false
# OK
# Nicolas_Ardelean   true                     true           true                          false
# Sanford_Dietrich   false                    false          false                         false
# OK
# Sanford_Dietrich   true                     true           true                          false
# Matt_Hill          false                    false          false                         false
# OK
# Matt_Hill          true                     true           true                          false
# Mike_Wilkins       true                     true           false                         false
# OK
# Mike_Wilkins       true                     true           true                          false
# 