require '../lib/momentum_api'

do_live_updates           =   false

scan_options = {
    team_category_watching:   true,
    essential_watching:       true,
    growth_first_post:        true,
    meta_first_post:          true,
    trust_level_updates:      true,
    score_user_levels:        true,
    user_group_alias_notify:  true
}

# @emails_from_username     =   'Kim_Miller'

# testing variables
target_username   = nil # Steven_Lang_Test Kim_test_Staged Randy_Horton Steve_Scott Marty_Fauth Kim_Miller Don_Morgan David_Kirk Brad_Fino
target_groups     = %w(trust_level_1)  # OwnerExpired Mods GreatX BraveHearts trust_level_1 trust_level_0

master_client = MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates=do_live_updates,
                                           target_groups=target_groups, target_username=target_username)

master_client.apply_to_users(scan_options)

master_client.scan_summary

# Jun 2, 2019
# UserName           Group              User's_Level    Group's_Default
# Tim_Tannatt        BraveHearts               2               3
#
# Kim_Miller         has not voted yet
#   Message From:    KM_Admin             Kim_Miller           Momentum's Discourse User Poll is Waiting for Your Input! Your input is very im     Pending
#
# UserName           Group                Category             Level      Status
# James_McKeefery    Fusion               Fusion                 1        NOT Watching
#
# UserName           Group                Category             Level      Status
# David_Kirk         Expedition01         Expedition01           1        NOT Watching
#
# UserName           Group              User's_Level    Group's_Default
# David_Ashby        moderators                2               3
# UserName           Group              User's_Level    Group's_Default
# David_Ashby        staff                     2               3