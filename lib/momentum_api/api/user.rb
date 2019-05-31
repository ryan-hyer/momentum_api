module MomentumApi
  module User

    def update_user_trust_level(is_owner, trust_level_target, user_details)

      # puts 'update_trust_level'
      if @issue_users.include?(user_details['username'])
        puts "#{user_details['username']}  is_owner: #{is_owner}\n"
      end

      if is_owner
        # puts 'Is owner 2nd check true'
      else
        # what to update
        if user_details['trust_level'] == trust_level_target
          # puts 'User already correct'
        else

          user_option_print = %w(
            last_seen_at
            last_posted_at
            post_count
            time_read
            recent_time_read
            trust_level
          )

          print_user_options(user_details, user_option_print, 'Non Owner')
          # puts 'User to be updated'
          @user_targets += 1
          if self.do_live_updates

            update_response = @admin_client.update_trust_level(user_id: user_details['id'], level: trust_level_target)
            puts "#{update_response['admin_user']['username']} Updated"
            @users_updated += 1

            # check if update happened
            user_details_after_update = @admin_client.user(user_details['username'])
            print_user_options(user_details_after_update, user_option_print, 'Non Owner')
            sleep(1)
          end
        end
      end
    end

  end
end
