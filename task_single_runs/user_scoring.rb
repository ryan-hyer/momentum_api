require '../../lib/momentum_api'

do_live_updates   = false

# testing variables
target_username   = 'David_Kirk' # David_Kirk Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
target_groups     = %w(Mods)  # Mods GreatX BraveHearts (trust_level_1 trust_level_0 hits 100 record limit)

master_client = MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates=do_live_updates,
                                           target_groups=target_groups, target_username=target_username)

scan_options = {
    score_user_levels: {
        update_type:  'have_voted',      # have_voted, not_voted, newly_voted, all
        target_post:  28707,            # 28649
        target_polls: %w(version_two),  # basic new version_two
        poll_url:     'https://discourse.gomomentum.org/t/user-persona-survey/6485/20'
    }
}

master_client.apply_to_users(scan_options)

master_client.scan_summary
