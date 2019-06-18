require '../lib/momentum_api'

discourse_options = {
    do_live_updates:            false,
    target_username:            nil,
    target_groups:              %w(Mods),
    instance:                   'live',
    api_username:               'KM_Admin',
    exclude_users:              %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin),
    issue_users:                %w()
}

schedule_options = {
    team_category_watching:     true,
    essential_watching:         true,
    growth_first_post:          true,
    meta_first_post:            true,
    trust_level_updates:        true,
    score_user_levels: {
        update_type:    'not_voted', # have_voted, not_voted, newly_voted, all
        target_post:    28707, # 28649
        target_polls:   %w(version_two), # basic new version_two
        poll_url:       'https://discourse.gomomentum.org/t/what-s-your-score'
    },
    user_group_alias_notify:    true
}

discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary

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
