require '../utility/momentum_api'
require '../users/trust_level'
require '../notifications/users_update_global_category_watching'

@do_live_updates = false
@instance = 'live' # 'live' or 'local'

@exclude_user_names = %w(system discobot js_admin sl_admin JP_Admin admin_sscott RH_admin KM_Admin Winston_Churchill
                            Joe_Sabolefski Steve_Scott Howard_Bailey)

# testing variables
@target_username = 'Brad_Fino' # John_Oberstar Randy_Horton Steve_Scott Marty_Fauth Joe_Sabolefski Don_Morgan
# @target_groups = %w(BraveHearts)  # BraveHearts trust_level_1 trust_level_0 hit 100 record limit.
@issue_users = %w() # past in debug issue user_names Brad_Fino

@user_count, @user_targets, @new_user_score_targets, @users_updated, @user_not_voted_targets, @new_user_badge_targets,
    @sent_messages = 0, 0, 0, 0, 0, 0, 0
# @user_count = 0
@matching_user_count = 0
@matching_categories_count = 0
@categories_updated = 0

def print_user(user, category, group_name, notify_level)
  field_settings = "%-18s %-20s %-20s %-10s %-15s\n"
  printf field_settings, 'UserName', 'Group', 'Category', 'Level', 'Status'
  printf field_settings, user['username'], group_name, category['slug'], notify_level.to_s.center(5), 'NOT_Watching'
end

def print_user_options(user_details, user_option_print)
  field_settings = "%-18s %-14s %-16s %-12s %-12s %-17s %-14s\n"
  printf field_settings, 'UserName',
         user_option_print[0], user_option_print[1], user_option_print[2],
         user_option_print[3], user_option_print[4], user_option_print[5]

  printf field_settings, user_details['username'],
         user_details[user_option_print[0].to_s].to_s[0..9], user_details[user_option_print[1].to_s].to_s[0..9],
         user_details[user_option_print[2].to_s], user_details[user_option_print[3].to_s],
         user_details[user_option_print[4].to_s], user_details[user_option_print[5].to_s]
end

def category_cases(client, user, users_categories, group_name)
  users_categories.each do |category|

    if @issue_users.include?(user['username'])
      puts "\n#{user['username']}  Category case on category: #{category['slug']}\n"
    end

    case
    when category['slug'] == 'Essential'
      case_excludes = %w()
      if case_excludes.include?(user['username'])
        puts "#{user['username']} specifically excluded from Essential Watching"
      else                            # 4 = Watching first post, 3 = Watching, 1 = blank or ...?
        set_category_notification(user, category, client, group_name, [3], 3)
      end

    when category['slug'] == 'Growth'
      case_excludes = %w(Bill_Herndon Michael_Wilson)
      if case_excludes.include?(user['username'])
        # puts "#{user['username']} specifically excluded from Watching Growth"
      else
        set_category_notification(user, category, client, group_name, [3, 4], 4)
      end

    when category['slug'] == 'Meta'
      case_excludes = %w(Bill_Herndon Michael_Wilson)
      if case_excludes.include?(user['username'])
        # puts "#{user['username']} specifically excluded from Watching Meta"
      else
        set_category_notification(user, category, client, group_name, [3, 4], 4)
      end

    else
      # puts 'Category not a target'
    end
  end
end

def apply_function(client, user)
  @user_count += 1
  @starting_categories_updated = @categories_updated
  user_details = client.user(user['username'])
  users_groups = user_details['groups']
  users_categories = client.categories
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

    # Group Filtered Category Cas
    if @target_groups and @target_groups.include?(group_name)
        category_cases(client, user, users_categories, group_name)
    end

    # Group Cases (make a method)
    case
    when group_name == 'Owner'
      is_owner = true
    else
      # puts 'No Group Case'
    end
  end

  # Unfiltered category case
  if  @target_groups
    # puts 'Not group filter'
  else
    category_cases(client, user, users_categories, 'Any')
  end

  # Update Trust Level
  update_trust_level(client, is_owner, 0, user, user_details)

  if @categories_updated > @starting_categories_updated
    @users_updated += 1
  end
end

if __FILE__ == $0

  apply_to_all_users(needs_user_client=true)

  puts "\n#{@matching_categories_count} matching Categories for #{@matching_user_count} Users found out of #{@user_count} processed and #{@skipped_users} skipped."
  puts "\n#{@categories_updated} Category notification_levels updated for #{@users_updated} Users."

end
