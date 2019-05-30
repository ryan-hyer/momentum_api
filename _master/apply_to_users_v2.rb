require '../lib/momentum_api'
# require '../users_scores/user_scoring'


def category_cases(master_client, user_details, users_categories, group_name, user_client)
  starting_categories_updated = master_client.categories_updated

  users_categories.each do |category|

    if master_client.issue_users.include?(user_details['username'])
      puts "\n#{user_details['username']}  Category case on category: #{category['slug']}\n"
    end

    case
    when category['slug'] == group_name
      case_excludes = %w(Steve_Scott)
      if case_excludes.include?(user_details['username'])
        # puts "#{user_details['username']} specifically excluded from Watching Meta"
      else
        if @team_category_watching
          master_client.set_category_notification(user_details, category, user_client, group_name, [3], 3)
        end
      end

    when (category['slug'] == 'Essential' and group_name == 'Owner')
      case_excludes = %w(Steve_Scott)
      if case_excludes.include?(user_details['username'])
        # puts "#{user_details['username']} specifically excluded from Essential Watching"
      else                            # 4 = Watching first post, 3 = Watching, 1 = blank or ...?
        if @essential_watching
          master_client.set_category_notification(user_details, category, user_client, group_name, [3], 3)
        end
      end

    when (category['slug'] == 'Growth' and group_name == 'Owner')
      case_excludes = %w(Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
      if case_excludes.include?(user_details['username'])
        # puts "#{user_details['username']} specifically excluded from Watching Growth"
      else
        if @growth_first_post
          master_client.set_category_notification(user_details, category, user_client, group_name, [3, 4], 4)
        end
      end

    when (category['slug'] == 'Meta' and group_name == 'Owner')
      case_excludes = %w(Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
      if case_excludes.include?(user_details['username'])
        # puts "#{user_details['username']} specifically excluded from Watching Meta"
      else
        if @meta_first_post
          master_client.set_category_notification(user_details, category, user_client, group_name, [3, 4], 4)
        end
      end

    else
      # puts 'Category not a target'
    end
  end
  if master_client.categories_updated > starting_categories_updated
    master_client.users_updated += 1
  end
end

def apply_function(master_client, user_details, user_client)
  users_groups = user_details['groups']
  begin
    users_categories = user_client.categories
  rescue DiscourseApi::UnauthenticatedError
    users_categories = nil
    puts "\n#{user_details['username']} : DiscourseApi::UnauthenticatedError - You are not permitted to view the requested resource.\n"
  end
  sleep 1

  is_owner = false
  if master_client.issue_users.include?(user_details['username'])
    puts "#{user_details['username']} in apply_function"
  end

  # Examine Users Groups
  users_groups.each do |group|
    group_name = group['name']

    if master_client.issue_users.include?(user_details['username'])
      puts "\n#{user_details['username']}  with group: #{group_name}\n"
    end

    if users_categories
      category_cases(master_client, user_details, users_categories, group_name, user_client)
    else
      puts "\nSkipping Category Cases for #{user_details['username']}.\n"
    end

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
    master_client.update_user_trust_level(is_owner, 0, user_details)
  end

  # Update User Group Alias Notification
  if @user_group_alias_notify
    master_client.user_group_notify_to_default(user_details)
  end

  # User Scoring
  if @score_user_levels
    update_type = 'newly_voted' # have_voted, not_voted, newly_voted, all
    target_post = 28707    # 28649
    target_polls = %w(version_two) # basic new version_two
    poll_url = 'https://discourse.gomomentum.org/t/user-persona-survey/6485/20'
    scan_users_score(user_client, user_details, target_post, target_polls, poll_url, update_type = update_type,
                     do_live_updates = @do_live_updates)
  end

end

# def run_tasks_for_all_users(do_live_updates=false)
#   @do_live_updates = do_live_updates
#
#   zero_counters
#
#   if @target_groups
#     @target_groups.each do |group_plug|
#       apply_to_group_users(group_plug, needs_user_client=true, skip_staged_user=true)
#     end
#   else
#     apply_to_all_users(needs_user_client=true)
#   end
#
# end

if __FILE__ == $0

  @team_category_watching   =   true
  @essential_watching       =   true
  @growth_first_post        =   true
  @meta_first_post          =   true
  @trust_level_updates      =   true
  @score_user_levels        =   false
  @user_group_alias_notify  =   true

  @emails_from_username     =   'Kim_Miller'

  do_live_updates           =   false
  instance                  =   'live' # 'live' or 'local'

  # testing variables
  target_username = nil # Steven_Lang_Test Kim_test_Staged Randy_Horton Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
  target_groups = %w(trust_level_1)  # OwnerExpired Mods GreatX BraveHearts trust_level_1 trust_level_0

  master_client = MomentumApi::Client.new('KM_Admin', instance, do_live_updates=do_live_updates,
                                          target_groups=target_groups, target_username=target_username)

  master_client.apply_to_users(method(:apply_function))

  master_client.scan_summary

end
