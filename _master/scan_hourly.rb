require '../lib/momentum_api'

@scan_passes_end        =   20

discourse_options = {
    do_live_updates:            true,
    # target_username:            'KM_Admin',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller Don_Morgan KM_Admin
    target_groups:              %w(trust_level_1),   # Mods GreatX BraveHearts trust_level_0 trust_level_1
    instance:                   'live',
    api_username:               'KM_Admin',
    exclude_users:              %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:                %w()
}

schedule_options = {
    team_category_watching:     false,
    essential_watching:         false,
    growth_first_post:          false,
    meta_first_post:            false,
    trust_level_updates:        false,    # todo broken: Not seeing Owners
    score_user_levels: {
        update_type:    'newly_voted',    # have_voted, not_voted, newly_voted, all
        target_post:    30719,            # 28707 28649
        # target_polls:   %w(poll),  # testing was version_two
        poll_url:       'https://discourse.gomomentum.org/t/what-s-your-score',
        messages_from:  'Kim_Miller'
    },
    user_group_alias_notify:    false
}

# init
@scan_passes            =   0

def scan_hourly

  printf "%s\n", "Scanning #{@discourse.options[:target_groups]} Users for Tasks ..."
  @discourse.apply_to_users
  @scan_passes += 1
  printf "%s\n", "Pass #{@scan_passes} complete. Waiting 30 minutes ..."

  # printf "%s\n", "Waiting 30 minutes ..."
  # sleep 5
  sleep 60 * 30

  if @scan_passes < @scan_passes_end
    # printf "%s\n", 'Repeating Scan'
    scan_hourly
  else
    printf "%s\n", '... Exiting ...'
  end

end

@discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
# @discourse.apply_to_users

printf "\n%s\n", 'Starting Scan ...'

scan_hourly

@discourse.scan_summary

# todo save log to disk
# todo tests
