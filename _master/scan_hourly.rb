require '../lib/momentum_api'

@scan_passes_end                =   40

discourse_options = {
    do_live_updates:                true,
    # target_username:              'KM_Admin',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller Don_Morgan KM_Admin
    target_groups:                  %w(trust_level_1),   # Mods GreatX BraveHearts trust_level_0 trust_level_1
    instance:                       'live',
    api_username:                   'KM_Admin',
    exclude_users:                  %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:                    %w()
}

schedule_options = {
    watching:{
        matching_team:              {
            allowed_levels:         [3],
            set_level:               3
        },
        essential:                  {
            allowed_levels:         [3],
            set_level:               3
        },
        growth:                     {
            allowed_levels:         [3, 4],
            set_level:               4
        },
        meta:                       {
            allowed_levels:         [3, 4],
            set_level:               4
        },
        group_alias:                true
    },
    trust_level_updates:            false,    # todo broken: Not seeing Owners
    user_scores: {
        update_type:                'newly_voted',    # have_voted, not_voted, newly_voted, all
        target_post:                30719,            # 28707 28649
        # target_polls:             %w(poll),  # testing was version_two
        poll_url:                   'https://discourse.gomomentum.org/t/what-s-your-score/7104',
        messages_from:              'Kim_Miller'
    },
}

# init
@scan_passes            =   0

def scan_hourly

  printf "%s\n", "Scanning #{@discourse.options[:target_groups]} Users for Tasks"
  @discourse.apply_to_users
  @scan_passes += 1
  printf "\n%s\n", "Pass #{@scan_passes} complete. Waiting 5 minutes ..."
  sleep 5 * 60

  if @scan_passes < @scan_passes_end
    @discourse.counters[:'Processed Users'], @discourse.counters[:'Skipped Users'] = 0, 0
    scan_hourly
  else
    printf "%s\n", '... Exiting ...'
  end

end

@discourse = MomentumApi::Discourse.new(discourse_options, schedule_options)

printf "\n%s\n\n", 'Starting Scan ...'

scan_hourly

@discourse.scan_summary

# todo save log to disk
# todo tests
