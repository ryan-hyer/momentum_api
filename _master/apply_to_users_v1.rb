require '../utility/momentum_api'
require '../users/trust_level'
require '../notifications/user_update_category_notification_level'
require '../users_scores/user_scoring'


def print_user(user, category, group_name, notify_level)
  field_settings = "%-18s %-20s %-20s %-10s %-15s\n"
  printf field_settings, 'UserName', 'Group', 'Category', 'Level', 'Status'
  printf field_settings, user['username'], group_name, category['slug'], notify_level.to_s.center(5), 'NOT_Watching'
end

def category_cases(client, user, users_categories, group_name)
  @starting_categories_updated = @categories_updated

  users_categories.each do |category|

    if @issue_users.include?(user['username'])
      puts "\n#{user['username']}  Category case on category: #{category['slug']}\n"
    end

    case
    when category['slug'] == group_name
      case_excludes = %w(Steve_Scott)
      if case_excludes.include?(user['username'])
        # puts "#{user['username']} specifically excluded from Watching Meta"
      else
        if @team_category_watching
          # puts user['username']
          # puts category['slug']
          # puts category['notification_level']
          set_category_notification(user, category, client, group_name, [3], 3,
                                    do_live_updates = @do_live_updates)
        end
      end

    when (category['slug'] == 'Essential' and group_name == 'Owner')
      case_excludes = %w(Steve_Scott)
      if case_excludes.include?(user['username'])
        # puts "#{user['username']} specifically excluded from Essential Watching"
      else                            # 4 = Watching first post, 3 = Watching, 1 = blank or ...?
        if @essential_watching
          set_category_notification(user, category, client, group_name, [3], 3,
                                    do_live_updates = @do_live_updates)
        end
      end

    when (category['slug'] == 'Growth' and group_name == 'Owner')
      case_excludes = %w(Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
      if case_excludes.include?(user['username'])
        # puts "#{user['username']} specifically excluded from Watching Growth"
      else
        if @growth_first_post
          set_category_notification(user, category, client, group_name, [3, 4], 4,
                                    do_live_updates = @do_live_updates)
        end
      end

    when (category['slug'] == 'Meta' and group_name == 'Owner')
      case_excludes = %w(Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
      if case_excludes.include?(user['username'])
        # puts "#{user['username']} specifically excluded from Watching Meta"
      else
        if @meta_first_post
          set_category_notification(user, category, client, group_name, [3, 4], 4,
                                    do_live_updates = @do_live_updates)
        end
      end

    else
      # puts 'Category not a target'
    end
  end
  if @categories_updated > @starting_categories_updated
    @users_updated += 1
  end
end

def apply_function(user, admin_client, user_client='')
  # @user_count += 1
  # printf "%s\n", user['username']
  user_details = user_client.user(user['username'])       # todo move to apply_to_all_users and trap DiscourseApi::TooManyRequests
  sleep(2)
  users_groups = user_details['groups']
  users_categories = user_client.categories
  sleep(2)

  is_owner = false
  if @issue_users.include?(user['username'])
    puts "#{user['username']} in apply_function"
  end

  # Examine Users Groups
  users_groups.each do |group|
    group_name = group['name']

    if @issue_users.include?(user['username'])
      puts "\n#{user['username']}  with group: #{group_name}\n"
    end

    category_cases(user_client, user, users_categories, group_name)

    # Group Cases (make a method)
    case
    when group_name == 'Owner'
      is_owner = true
    else
      # puts 'No Group Case'
    end
  end

  # Update Trust Level
  if @trust_level_updates
    update_trust_level(admin_client, is_owner, 0, user, user_details, do_live_updates = @do_live_updates)
  end

  # User Scoring
  if @score_user_levels
    update_type = 'newly_voted' # have_voted, not_voted, newly_voted, all
    target_post = 28707    # 28649
    target_polls = %w(version_two) # basic new version_two
    poll_url = 'https://discourse.gomomentum.org/t/user-persona-survey/6485/20'
    scan_users_score(user_client, user, target_post, target_polls, poll_url, update_type = update_type,
                     do_live_updates = @do_live_updates)
  end

end

def run_tasks_for_all_users(do_live_updates=false)
  @do_live_updates = do_live_updates

  zero_counters

  if @target_groups
    @target_groups.each do |group_plug|
      apply_to_group_users(group_plug, needs_user_client=true, skip_staged_user=true)
    end
  else
    apply_to_all_users(needs_user_client=true)
  end

end

if __FILE__ == $0

  do_live_updates = false
  @instance = 'live' # 'live' or 'local'
  @emails_from_username = 'Kim_Miller'

  @exclude_user_names = %w(system discobot js_admin sl_admin JP_Admin admin_sscott RH_admin KM_Admin Winston_Churchill
                            Joe_Sabolefski)

  # testing variables
  # @target_username = 'Kim_Miller' # John_Oberstar Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
  @target_groups = %w(Mods)  # GreatX BraveHearts trust_level_1 trust_level_0 hit 100 record limit.
  @issue_users = %w() # past in debug issue user_names Brad_Fino

  scan_summary

  run_tasks_for_all_users(do_live_updates=do_live_updates)

  scan_summary

end
