require '../lib/momentum_api'

# def apply_function(master_client, user_details, user_client)
#   starting_categories_updated = master_client.categories_updated
#   # @users_username = user_details['username']
#   @users_groups = user_client.user(user_details['username'])['groups']
#   sleep 1
#   @users_categories = user_client.categories
#   sleep 1
#
#   if @issue_users.include?(@users_username)
#     puts @users_username
#   end
#
#   @users_groups.each do |group|
#     if @target_groups
#       group_name = group['name']
#       # puts group_name
#     else
#       group_name = 'Any'
#     end
#
#     if @issue_users.include?(@users_username)
#       puts "\n#{@users_username}  Group: #{group_name}\n"
#     end
#
#     if not @target_groups or @target_groups.include?(group_name)
#
#       @users_categories.each do |category|
#         @category_slug = category['slug']
#
#         if @issue_users.include?(@users_username)
#           puts "\n#{@users_username}  Category: #{@category_slug}\n"
#         end
#
#         if @target_category_slugs.include?(@category_slug)
#           master_client.set_category_notification(user_details, category, user_client, group_name, @acceptable_notification_levels,
#                                     @set_notification_level)
#         end
#       end
#       break
#     end
#   end
#   if master_client.categories_updated > starting_categories_updated
#     master_client.users_updated += 1
#   end
# end


if __FILE__ == $0

  do_live_updates   = false
  instance          = 'live' # 'live' or 'local'

  # testing variables
  target_username   = nil # Kim_test_Staged Randy_Horton Steve_Scott Marty_Fauth Kim_Miller Don_Morgan
  target_groups     = %w(Alignment)  # Mods GreatX BraveHearts Alignment

  master_client     = MomentumApi::Client.new('KM_Admin', instance, do_live_updates=do_live_updates,
                                              target_groups=target_groups, target_username=target_username)

  scan_options = {
      team_category_watching: true,
  }

  master_client.apply_to_users(scan_options)

  master_client.scan_summary

end
