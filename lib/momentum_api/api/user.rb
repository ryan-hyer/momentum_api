module MomentumApi
  module User

    def update_user_trust_level(discourse, man, trust_level_target)

      user_option_print = %w(
            last_seen_at
            last_posted_at
            post_count
            time_read
            recent_time_read
            trust_level
          )

      # puts 'update_trust_level'
      if discourse.issue_users.include?(man.user_details['username'])
        puts "#{man.user_details['username']}  Is Owner"
      end

      # what to update
      if man.user_details['trust_level'] == trust_level_target
        # print_user_options(man.user_details, user_option_print, 'Correct Trust')
      else
        print_user_options(man.user_details, user_option_print, 'Non Owner')
        # puts 'User to be updated'
        # discourse.user_targets += 1     # todo update with notifications class
        if discourse.do_live_updates

          update_response = discourse.admin_client.update_trust_level(user_id: man.user_details['id'], level: trust_level_target)
          puts "#{update_response['admin_user']['username']} Updated"
          discourse.users_updated += 1

          # check if update happened
          user_details_after_update = discourse.admin_client.user(man.user_details['username'])
          print_user_options(user_details_after_update, user_option_print, 'Non Owner')
          sleep(1)
        end
      end
    end

  end
end
