require '../lib/momentum_api'

@scan_passes_end                =   60

discourse_options = {
    do_live_updates:                true,
    # target_username:              'David_Ashby',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller David_Ashby KM_Admin
    target_groups:                  %w(trust_level_1),   # Mods GreatX BraveHearts trust_level_0 trust_level_1
    instance:                       'live',
    api_username:                   'KM_Admin',
    exclude_users:                  %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:                    %w(KM_Admin)
}

schedule_options = {
    category:{
        matching_team:              {
            allowed_levels:         [3],
            set_level:               3,
            excludes:               %w(Steve_Scott Ryan_Hyer David_Kirk)
        },
        essential:                  {
            allowed_levels:         [3],
            set_level:               3,
            excludes:               %w(Steve_Scott Joe_Sabolefski)
        },
        growth:                     {
            allowed_levels:         [3, 4],
            set_level:               4,
            excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
        },
        meta:                       {
            allowed_levels:         [3, 4],
            set_level:               4,
            excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
        }
    },
    group:{
        group_alias:               {
            allowed_levels:         nil,              # Default: 3
            set_level:              nil,              # Default: 3
            excludes:               %w()
        }
    },
    user:{
        downgrade_non_owner_trust:                {
            allowed_levels:         0,                # Default: 0
            set_level:              0,                # Default: 0
            excludes:               %w()
        }
    },
    user_scores: {
        update_type:                'newly_voted',    # have_voted, not_voted, newly_voted, all
        target_post:                30719,            # 28707 28649
        # target_polls:             %w(poll),  # testing was version_two
        poll_url:                   'https://discourse.gomomentum.org/t/what-s-your-score/7104',
        messages_from:              'Kim_Miller',
        excludes:                   %w(Mike_Ehlers)
    }
}

# init
@scan_passes                    =   0

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

# Jun 25, 2019
# Scanning ["trust_level_1"] Users for Tasks
# Scanning ["trust_level_1"] Users for Tasks
# CategoryUser       Group                Category             Level      Status
# Andrew_Webster     Owner                Meta                   1        NOT Watching
# {"success"=>"OK"}
# Updated Category: Meta    Notification Level: 4
# Non Owner          last_seen_at   last_posted_at   post_count   time_read    recent_time_read  trust_level
# Brad_Fino          2018-03-09     2018-01-08       16           4936         0                 1
# Brad_Fino Updated
# Non Owner          last_seen_at   last_posted_at   post_count   time_read    recent_time_read  trust_level
# Brad_Fino          2018-03-09     2018-01-08       16           4936         0                 0
# CategoryUser       Group                Category             Level      Status
# Clay_Campbell      RightStuff           RightStuff             1        NOT Watching
# {"success"=>"OK"}
# Updated Category: RightStuff    Notification Level: 3
# GroupUser          Group                Category             Level      Status
# David_Ashby        moderators           na                     2        NOT Group Default of 3
# {"success"=>"OK"}
# Updated Group: moderators    Notification Level: 3    Set Level: 3
# GroupUser          Group                Category             Level      Status
# David_Ashby        staff                na                     2        NOT Group Default of 3
# {"success"=>"OK"}
# Updated Group: staff    Notification Level: 3    Set Level: 3
# CategoryUser       Group                Category             Level      Status
# Ian_Wilkes         Council25            Council25              1        NOT Watching
# {"success"=>"OK"}
# Updated Category: Council25    Notification Level: 3
# GroupUser          Group                Category             Level      Status
# Mike_Drilling      admins               na                     2        NOT Group Default of 3
# {"success"=>"OK"}
# Updated Group: admins    Notification Level: 3    Set Level: 3
# GroupUser          Group                Category             Level      Status
# Mike_Drilling      staff                na                     2        NOT Group Default of 3
# {"success"=>"OK"}
# Updated Group: staff    Notification Level: 3    Set Level: 3
# GroupUser          Group                Category             Level      Status
# Tim_Tannatt        BraveHearts          na                     2        NOT Group Default of 3
# {"success"=>"OK"}
# Updated Group: BraveHearts    Notification Level: 3    Set Level: 3
# Scanning User:  166 