require '../lib/momentum_api'

do_live_updates           =   false

scan_options = {                        # todo move to using the Class from this point forward.
    team_category_watching:   true,
    essential_watching:       true,
    growth_first_post:        true,
    meta_first_post:          true,
    trust_level_updates:      true,
    score_user_levels: {
        update_type:  'not_voted',      # have_voted, not_voted, newly_voted, all
        target_post:  28707,            # 28649
        target_polls: %w(version_two),  # basic new version_two
        poll_url:     'https://discourse.gomomentum.org/t/user-persona-survey/6485/20'
    },
    user_group_alias_notify:  true
}

# @emails_from_username     =   'Kim_Miller'

# testing variables
target_username   = nil # Steven_Lang_Test Kim_test_Staged Randy_Horton Steve_Scott Marty_Fauth Kim_Miller Don_Morgan David_Kirk Brad_Fino
target_groups     = %w(Mods)  # OwnerExpired Mods Committed GreatX BraveHearts trust_level_1 trust_level_0

master_client = MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates=do_live_updates,
                                           target_groups=target_groups, target_username=target_username)

master_client.apply_to_users(scan_options)

master_client.scan_summary

# Jun 2, 2019
# GroupUser          Group                Category             Level      Status
# David_Ashby        moderators           na                     2        NOT Group Default of 3
# GroupUser          Group                Category             Level      Status
# David_Ashby        staff                na                     2        NOT Group Default of 3
# CategoryUser       Group                Category             Level      Status
# David_Kirk         Expedition01         Expedition01           1        NOT Watching
# CategoryUser       Group                Category             Level      Status
# James_McKeefery    Fusion               Fusion                 1        NOT Watching
# CategoryUser       Group                Category             Level      Status
# John_Nadler        Committed            Committed              1        NOT Watching
# Kim_Miller         has not voted yet
#   Message From:    KM_Admin             Kim_Miller           Momentum's Discourse User Poll is Waiting for Your Input! Your input is very im     Pending
#
# GroupUser          Group                Category             Level      Status
# Tim_Tannatt        BraveHearts          na                     2        NOT Group Default of 3
# CategoryUser       Group                Category             Level      Status
# Tony_Christopher   Committed            Committed              1        NOT Watching
# Scanning User:  162
# Category Notification Totals
# Categories Visible to Users:        680
# Users Needing Update:               4
# Updated Categories:                 0
# Updated Users:                      0
