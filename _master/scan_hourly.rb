require '../lib/momentum_api'

@scan_passes_end        =   1
@scan_passes            =   0

discourse_options = {
    do_live_updates:            false,
    target_username:            nil,
    target_groups:              %w(trust_level_1),   # Mods GreatX BraveHearts trust_level_0 trust_level_1
    instance:                   'live',
    api_username:               'KM_Admin',
    exclude_users:              %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:                %w()
}

schedule_options = {
    team_category_watching:     true,
    essential_watching:         true,
    growth_first_post:          true,
    meta_first_post:            true,
    trust_level_updates:        false,    # todo broken: Not seeing Owners
    score_user_levels: {
        update_type:    'newly_voted',    # have_voted, not_voted, newly_voted, all
        target_post:    28707,            # 28649
        target_polls:   %w(version_two),  # basic new version_two
        poll_url:       'https://discourse.gomomentum.org/t/user-persona-survey/6485/20',
        messages_from:  'Kim_Miller'
    },
    user_group_alias_notify:    false
}


def scan_hourly

  printf "\n%s\n", 'Scanning All-Users for Tasks ...'
  @discourse.apply_to_users
  @scan_passes += 1
  printf "%s\n", "\nPass #{@scan_passes} complete \n"

  printf "%s\n", "\nWaiting 1 hour ... \n"
  # sleep(60 * 60)

  if @scan_passes < @scan_passes_end
    printf "%s\n", 'Repeating Scan'
    scan_hourly
  else
    printf "%s\n", '... Exiting ...'
  end

end

@discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)
@discourse.apply_to_users

printf "\n%s\n", 'Starting Scan ...'

scan_hourly

@discourse.scan_summary

# todo save log to disk
# todo tests
