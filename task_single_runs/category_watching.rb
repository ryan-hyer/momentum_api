require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        false,
    # target_username:        'Ian_Wilkes',       # David_Kirk Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
    target_groups:          %w(trust_level_1),  # Mods GreatX BraveHearts trust_level_0 trust_level_1
    instance:               'live',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:             %w()
}

schedule_options =   {
    watching:{
        matching_team:              {
            allowed_levels:         [3],
            set_level:               3,
            excludes:               %w(Steve_Scott Ryan_Hyer David_Kirk)
        }
        # essential:                  {
        #     allowed_levels:         [3],
        #     set_level:               3,
        #     excludes:               %w(Steve_Scott Joe_Sabolefski)
        # },
        # growth:                     {
        #     allowed_levels:         [3, 4],
        #     set_level:               4,
        #     excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
        # },
        # meta:                       {
        #     allowed_levels:         [3, 4],
        #     set_level:               4,
        #     excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
        # },
        # group_alias:                true
    # },
    # trust_level_updates:          true,
    # user_scores: {
    #     update_type:              'not_voted', # have_voted, not_voted, newly_voted, all
    #     target_post:              28707, # 28649
    #     target_polls:           %w(poll), # basic new version_two
        # poll_url:                 'https://discourse.gomomentum.org/t/what-s-your-score',
        # messages_from:            'Kim_Miller'
    }
}

discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
discourse.apply_to_users
discourse.scan_summary
