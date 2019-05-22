require '../users/trust_level'
require '../users_scores/user_scoring'
require '../notifications/users_update_global_category_watching'
# require '../notifications/users_update_global_category_to_watching_first_post'

def scan_hourly

  puts 'Owner Trust Levels ... scanning ...'
  # scan_trust_levels(do_live_updates = false)
  # sleep(5 * 60)

  puts 'Poll User Scores ... scanning ...'
  # scan_user_scores(do_live_updates=false, update_type='newly_voted')
  # sleep(5 * 60)

  puts 'Essential Watching ... scanning ...'
  global_category_to_watching(do_live_updates=false , target_category_slugs=%w(Essential), acceptable_notification_levels=[3],
                              set_notification_level=3, exclude_user_names=%w())

  puts 'Meta Watching First Post ... scanning ...'
  # global_category_to_watching(do_live_updates=true, target_category_slugs=%w(Meta Growth), acceptable_notification_levels=[3, 4],
  #                             set_notification_level=4, exclude_user_names=%w(Bill_Herndon Michael_Wilson))

  # puts 'Routine Watching First Post ... scanning ...'  # excludes as of May 21, 2019
  # global_category_to_watching(do_live_updates=false, target_category_slugs=%w(Routine), acceptable_notification_levels=[3, 4],
  #                             set_notification_level=4, exclude_user_names=%w(Bill_Herndon Michael_Wilson Suhas_Chelian
  #                                                                             Madon_Snell David_Kirk Art_Muir Steve_Cross
  #                                                                             Dennis_Adsit Shane_Reed Janos_Keresztes))

  puts 'Repeating ...'
  scan_hourly

end

scan_hourly

