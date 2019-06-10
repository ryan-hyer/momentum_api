require '../lib/momentum_api'

def schedule_options
  {
      team_category_watching:   true,
      essential_watching:       true,
      growth_first_post:        true,
      meta_first_post:          true,
      trust_level_updates:      true,
      score_user_levels: {
          update_type:    'not_voted', # have_voted, not_voted, newly_voted, all
          target_post:    28707, # 28649
          target_polls:   %w(version_two), # basic new version_two
          poll_url:       'https://discourse.gomomentum.org/t/user-persona-survey/6485/20'
      },
      user_group_alias_notify:  true
  }
end

def discourse_options
  {
      do_live_updates:          false,
      target_username:          'Tim_Tannatt',
      target_groups:            %w(trust_level_1),
      instance:                 'live',
      api_username:             'KM_Admin'
  }
end

master_client = MomentumApi::Discourse.new(discourse_options, schedule_options)

scan_options = {
    user_group_alias_notify:  true
}

master_client.apply_to_users(scan_options)

master_client.scan_summary
