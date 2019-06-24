require '../lib/momentum_api'

@scan_passes_end                =   60

discourse_options = {
    do_live_updates:                true,
    # target_username:              'David_Ashby',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller Don_Morgan KM_Admin
    target_groups:                  %w(trust_level_1),   # Mods GreatX BraveHearts trust_level_0 trust_level_1
    instance:                       'live',
    api_username:                   'KM_Admin',
    exclude_users:                  %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
    issue_users:                    %w()
}

schedule_options = {
    # watching:{
    #     matching_team:              {
    #         allowed_levels:         [3],
    #         set_level:               3
    #     },
    #     essential:                  {
    #         allowed_levels:         [3],
    #         set_level:               3
    #     },
    #     growth:                     {
    #         allowed_levels:         [3, 4],
    #         set_level:               4
    #     },
    #     meta:                       {
    #         allowed_levels:         [3, 4],
    #         set_level:               4
    #     },
    #     group_alias:                true
    # },
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

# Jun 23, 2019 fix
# Scanning ["trust_level_1"] Users for Tasks
# User badge granted:                 Intermediate
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Antonio_Martinez   2019-06-24     2019-02-28       20           7173         1244
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Antonio_Martinez   2019-06-24     2019-02-28       20           7173         1244              232
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# Antonio_Martinez   poll                 0                                   232   /  1146    Intermediate
#   Message From:    Kim_Miller           Antonio_Martinez     Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           Antonio_Martinez     thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# User badge granted:                 Intermediate
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Bill_Herndon       2019-06-24     2019-06-11       23           13241        4781
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Bill_Herndon       2019-06-24     2019-06-11       23           13241        4781              57
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# Bill_Herndon       poll                 0                                   57    /  1146    Intermediate
#   Message From:    Kim_Miller           Bill_Herndon         Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           Bill_Herndon         thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Brian_Haskin       2019-06-24     2019-06-19       48           49840        11325             0
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Brian_Haskin       2019-06-24     2019-06-19       48           49840        11325             167
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# Brian_Haskin       poll                 0                                   167   /  1146    Intermediate
#   Message From:    Kim_Miller           Brian_Haskin         Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           Brian_Haskin         thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# User badge granted:                 Advanced
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Chris_Sulek        2019-06-24     2019-06-23       157          338594       39740
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Chris_Sulek        2019-06-24     2019-06-23       157          338594       39740             459
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# Chris_Sulek        poll                 0                                   459   /  1146    Advanced
#   Message From:    Kim_Miller           Chris_Sulek          Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           Chris_Sulek          thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Clay_Campbell      2019-06-24     2019-06-24       42           59145        2441              0
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Clay_Campbell      2019-06-24     2019-06-24       42           59145        2441              155
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# Clay_Campbell      poll                 0                                   155   /  1146    Intermediate
#   Message From:    Kim_Miller           Clay_Campbell        Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           Clay_Campbell        thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# User badge granted:                 Intermediate
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Curt_Weil          2019-06-24     2019-06-16       113          11015        328
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Curt_Weil          2019-06-24     2019-06-16       113          11015        328               73
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# Curt_Weil          poll                 0                                   73    /  1146    Intermediate
#   Message From:    Kim_Miller           Curt_Weil            Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           Curt_Weil            thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# User badge granted:                 Intermediate
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# James_Grubinskas   2019-06-24     2019-06-24       100          47926        29555             D3
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# James_Grubinskas   2019-06-24     2019-06-24       100          47926        29555             269
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# James_Grubinskas   poll                 0                                   269   /  1146    Intermediate
#   Message From:    Kim_Miller           James_Grubinskas     Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           James_Grubinskas     thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# User badge granted:                 Beginner
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Jim_Knapp          2019-06-24     2019-06-23       179          5250         1213
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Jim_Knapp          2019-06-24     2019-06-23       179          5250         1213              11
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# Jim_Knapp          poll                 0                                   11    /  1146    Beginner
#   Message From:    Kim_Miller           Jim_Knapp            Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           Jim_Knapp            thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# User badge granted:                 Advanced
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Krishna_Yetchina   2019-06-24     2019-06-24       114          154746       1961
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Krishna_Yetchina   2019-06-24     2019-06-24       114          154746       1961              742
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# Krishna_Yetchina   poll                 0                                   742   /  1146    Advanced
#   Message From:    Kim_Miller           Krishna_Yetchina     Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           Krishna_Yetchina     thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# Keep trying!
# User badge granted:                 Intermediate
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Tony_Christopher   2019-06-24     2019-05-30       44           27130        684
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Tony_Christopher   2019-06-24     2019-05-30       44           27130        684               74
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# Tony_Christopher   poll                 0                                   74    /  1146    Intermediate
#   Message From:    Kim_Miller           Tony_Christopher     Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           Tony_Christopher     thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# Scanning User:  166


# Jun 23, 2019 bug
# You ran out of gas.
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Alfonso_Benavides  2019-06-24     2019-06-24       182          239404       37649             401
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Alfonso_Benavides  2019-06-24     2019-06-24       182          239404       37649             0
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# Alfonso_Benavides  poll                 401                                 0     /  1146
#   Message From:    Kim_Miller           Alfonso_Benavides    Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           Alfonso_Benavides    thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# You ran out of gas.
# You ran out of gas.
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Brian_Haskin       2019-06-24     2019-06-19       48           49840        11325             167
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Brian_Haskin       2019-06-24     2019-06-19       48           49840        11325             0
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# Brian_Haskin       poll                 167                                 0     /  1146
#   Message From:    Kim_Miller           Brian_Haskin         Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           Brian_Haskin         thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# You ran out of gas.
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Clay_Campbell      2019-06-23     2019-06-16       42           58860        2156              155
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# Clay_Campbell      2019-06-23     2019-06-16       42           58860        2156              0
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# Clay_Campbell      poll                 155                                 0     /  1146
#   Message From:    Kim_Miller           Clay_Campbell        Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           Clay_Campbell        thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
#
# You ran out of gas.
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# David_Ashby        2019-06-23     2019-06-21       93           53283        28851             942
# OK
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  user_field_score
# David_Ashby        2019-06-23     2019-06-21       93           53283        28851             0
# User               Poll                 Last Saved Score                    Score /  Max     Badge
# David_Ashby        poll                 942                                 0     /  1146
#   Message From:    Kim_Miller           David_Ashby          Thank You for Taking Momentum's Discourse User Quiz     Congratulations! Your     Pending
#   Message From:    Kim_Miller           David_Ashby          thank-you-for-taking-momentums-discourse-user-quiz      Congratulations! Your     Sent
