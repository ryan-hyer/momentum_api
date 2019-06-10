module MomentumApi
  module User

    def update_user_trust_level(master_client, trust_level_target, user_details)

      user_option_print = %w(
            last_seen_at
            last_posted_at
            post_count
            time_read
            recent_time_read
            trust_level
          )

      # puts 'update_trust_level'
      if master_client.issue_users.include?(user_details['username'])
        puts "#{user_details['username']}  Is Owner"
      end

      # if is_owner
        print_user_options(user_details, user_option_print, 'Is Owner')
      # else
        # what to update
      if user_details['trust_level'] == trust_level_target
        # print_user_options(user_details, user_option_print, 'Correct Trust')
      else

        print_user_options(user_details, user_option_print, 'Non Owner')
        # puts 'User to be updated'
        master_client.user_targets += 1
        if master_client.do_live_updates

          update_response = master_client.admin_client.update_trust_level(user_id: user_details['id'], level: trust_level_target)
          puts "#{update_response['admin_user']['username']} Updated"
          master_client.users_updated += 1

          # check if update happened
          user_details_after_update = master_client.admin_client.user(user_details['username'])
          print_user_options(user_details_after_update, user_option_print, 'Non Owner')
          sleep(1)
        end
      end

      # end
    end

  end
end
