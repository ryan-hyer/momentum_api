require '../_master/apply_to_users'
require '../users/trust_level'
require '../users_scores/user_scoring'
require '../notifications/users_update_global_category_watching'
# require '../notifications/users_update_global_category_to_watching_first_post'

@do_live_updates = false
@instance = 'live' # 'live' or 'local'

@exclude_user_names = %w(system discobot js_admin sl_admin JP_Admin admin_sscott RH_admin KM_Admin Winston_Churchill
                            Joe_Sabolefski Steve_Scott Howard_Bailey)

# testing variables
# @target_username = 'Brad_Fino' # John_Oberstar Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
# @target_groups = %w(BraveHearts)  # BraveHearts trust_level_1 trust_level_0 hit 100 record limit.
@issue_users = %w() # past in debug issue user_names Brad_Fino

@user_count, @user_targets, @new_user_score_targets, @users_updated, @user_not_voted_targets, @new_user_badge_targets,
    @sent_messages = 0, 0, 0, 0, 0, 0, 0
@matching_user_count, @matching_categories_count, @categories_updated = 0, 0, 0

def scan_hourly

  puts 'All-User tasks ... scanning ...'
  run_tasks_for_all_users(do_live_updates=false)

  puts 'Poll User Scores ... scanning ...'
  # scan_user_scores(do_live_updates=false, update_type='newly_voted')
  # sleep(5 * 60)

  # puts 'Essential Watching ... scanning ...'
  global_category_to_watching(do_live_updates=false, target_category_slugs=%w(Essential), acceptable_notification_levels=[3],
                              set_notification_level=3, exclude_user_names=%w())

  # puts 'Routine Watching First Post ... scanning ...'  # excludes as of May 21, 2019
  # global_category_to_watching(do_live_updates=false, target_category_slugs=%w(Routine), acceptable_notification_levels=[3, 4],
  #                             set_notification_level=4, exclude_user_names=%w(Bill_Herndon Michael_Wilson Suhas_Chelian
  #                                                                             Madon_Snell David_Kirk Art_Muir Steve_Cross
  #                                                                             Dennis_Adsit Shane_Reed Janos_Keresztes))

  puts 'Repeating ...'
  scan_hourly

end

scan_hourly

