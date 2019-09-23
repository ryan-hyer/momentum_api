module MomentumApi
  class Ownership

    attr_accessor :counters

    def initialize(schedule, ownership_options, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'options needs to be defined' if ownership_options.nil? or ownership_options.empty?

      # parameter setting
      @schedule               =   schedule
      @options                =   ownership_options
      @mock                   =   mock

      @message_client = @mock || MomentumApi::Messages.new(self, 'KM_Admin')

      # counter init
      @counters               =   {'Ownership': ''}
      schedule.discourse.scan_pass_counters << @counters

      zero_notifications_counters

    end

    def run(man)

      if @schedule.discourse.options[:issue_users].include?(man.user_details['username'])
        puts "#{man.user_details['username']} in Ownership"
      end

      clock = @mock || Date
      @man = man
      subscriptions = @man.user_client.membership_subscriptions(man.user_details['id'])

      @options.each do |ownership_type|
        next if ownership_type[0] == :settings
        ownership_type[1].each do |action|

          renews_value = man.user_details['user_fields'][action[1][:user_fields]]
          renew_ownership_code = renews_value ? renews_value[11..12] : nil

          if action[1][:excludes].include?(man.user_details['username'])
            # puts "#{man.user_details['username']} is Excluded from this Task."
          else

            # if user is on auto renewal, get latest_auto_renew_date
            latest_auto_renew_date = nil
            if ownership_type[0].to_s == 'auto' and not subscriptions.empty?
              subscriptions.each do |subscription|
                if action[1][:subscrption_name] and subscription['product'] and subscription['subscription_end_date'] and
                    subscription['product']['name'] == action[1][:subscrption_name] and
                    Date.valid_date?(subscription['subscription_end_date'][0..3].to_i,
                                     subscription['subscription_end_date'][5..6].to_i,
                                     subscription['subscription_end_date'][8..9].to_i)
                  subscription_renew_date = Date.parse(subscription['subscription_end_date'][0..9])
                  if latest_auto_renew_date
                    if subscription_renew_date > latest_auto_renew_date
                      latest_auto_renew_date = subscription_renew_date
                    end
                  else
                    latest_auto_renew_date = subscription_renew_date
                  end
                end
              end
            end
            
            # see if user has a valid renews date on his prfile
            if renews_value and Date.valid_date?(renews_value[0..3].to_i, renews_value[5..6].to_i, renews_value[8..9].to_i)

              profile_renew_date = Date.parse(renews_value[0..9])

              # alert renewing auto renewal is present
              if latest_auto_renew_date and latest_auto_renew_date > profile_renew_date and
                  action[1][:ownership_code] == 'CA' and action[1][:action_sequence] == 'R0'
                # effective_renew_date = latest_auto_renew_date
                effective_renews_value = latest_auto_renew_date.strftime("%Y-%m-%d") + ' ' +
                    action[1][:ownership_code] + ' ' + action[1][:action_sequence]
                update_ownership(man, action, effective_renews_value)
                break
              else
                effective_renew_date = profile_renew_date
                effective_renews_value = renews_value
              end

              action_date_qualifies = clock.today >= effective_renew_date - action[1][:days_until_renews]
              action_ownership_code_match = renew_ownership_code == action[1][:ownership_code]

              if action_ownership_code_match

                if effective_renews_value[14] == 'R' and effective_renews_value[15] =~ /^\d+$/

                  if action_date_qualifies

                    action_sequence_last = effective_renews_value[15].to_i
                    action_sequence_qualifies = action_sequence_last + 1 == action[1][:action_sequence][1].to_i

                    if action_sequence_qualifies

                      user_update_value = effective_renews_value[0..12] + ' ' + action[1][:action_sequence]
                      update_ownership(man, action, user_update_value)

                    end

                  end

                # alert manual renewal is present
                elsif ownership_type[0].to_s == 'manual' and action[1][:action_sequence] == 'R0'
                  user_update_value = effective_renews_value[0..12] + ' ' + action[1][:action_sequence]
                  update_ownership(man, action, user_update_value)
                end

              end

            # alert first time auto renewal is present
            elsif latest_auto_renew_date and action[1][:ownership_code] == 'CA' and action[1][:action_sequence] == 'R0'
              user_update_value = latest_auto_renew_date.strftime("%Y-%m-%d") + ' ' + 
                  action[1][:ownership_code] + ' ' + action[1][:action_sequence]
              update_ownership(man, action, user_update_value)

            # remove user from Onwership groups as he does not appear to have any memberships
            elsif action[1][:remove_from_group] and not latest_auto_renew_date and
                @options[:settings][:all_ownership_group_ids].include?(action[1][:remove_from_group])
              remove_from_group(action, man)

            end
          end
        end
      end
    end

    
    private
    
    def send_renewal_message(action, variable_hash: nil)
      message_file = action[1][:ownership_code] + '_' + action[1][:action_sequence].to_s
      message_subject = eval(message_body(message_file + '_subject.txt'))
      message_body = eval(message_body(message_file + '_body.txt'))
      @message_client.send_private_message(@man, message_body, message_subject, from_username: action[1][:message_from],
                                           to_username: action[1][:message_to], cc_username: action[1][:message_cc])
    end

    def update_ownership(man, action, user_update_value)

      man.print_user_options(man.user_details, user_label: "#{action[0]}",
                             nested_user_field: %W(#{'user_fields'} #{action[1][:user_fields]}))
      @counters[:'Ownership Targets'] += 1

      update_set_value = {"#{action[1][:user_fields]}": user_update_value}

      if @schedule.discourse.options[:do_live_updates] and action[1][:do_task_update]

        update_response = @schedule.discourse.admin_client.update_user(man.user_details['username'],
                                                                       user_fields: update_set_value)

        @schedule.discourse.options[:logger].warn "#{update_response[:body]['success']}"
        @counters[:'Ownership Updated'] += 1

        # check if update happened
        user_details_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])
        man.print_user_options(user_details_after_update, user_label: 'User After Update',
                               nested_user_field: %W(#{'user_fields'} #{action[1][:user_fields]}))
        @mock ? sleep(0) : sleep(1)

        # todo stay with current group remove w/auto or create auto case where admins are alerted, but not group moves happen
        add_to_owner_group(action, man)

        remove_from_group(action, man)

        send_renewal_message(action, variable_hash: user_details_after_update)

      end
    end

    def add_to_owner_group(action, man)
      if action[1][:add_to_group]
        user_already_in_group = false
        man.user_details['groups'].each do |group|
          if group['id'] == action[1][:add_to_group]
            user_already_in_group = true
          end
        end

        if user_already_in_group
          # puts 'User already in group'
        else
          update_response = @schedule.discourse.admin_client.group_add(action[1][:add_to_group],
                                                                       username: man.user_details['username'])
          @mock ? sleep(0) : sleep(1)
          @schedule.discourse.options[:logger].warn "Added man to Group #{action[1][:add_to_group]}: #{update_response['success']}"
          @counters[:'Users Added to Group'] += 1
          check_users_groups(man, action[1][:add_to_group])
        end
      end
    end

    def remove_from_group(action, man)
      if action[1][:remove_from_group] and @schedule.discourse.options[:do_live_updates] and action[1][:do_task_update]
        user_in_target_group = false
        man.user_details['groups'].each do |group|
          if group['id'] == action[1][:remove_from_group]
            user_in_target_group = true
          end
        end

        if user_in_target_group
          remove_response = @schedule.discourse.admin_client.group_remove(action[1][:remove_from_group],
                                                                          username: man.user_details['username'])
          @mock ? sleep(0) : sleep(1)
          @schedule.discourse.options[:logger].warn "Removed man from Group #{action[1][:remove_from_group]}: #{remove_response['success']}"
          @counters[:'Users Removed from Group'] += 1
          user_in_any_owner_group = check_users_groups(man, action[1][:remove_from_group])
          if user_in_any_owner_group
            # puts 'User still in an ownership group'
          elsif man.user_details['moderator']  
            @schedule.discourse.admin_client.revoke_moderation(man.user_details['id'])
            @schedule.discourse.options[:logger].warn "#{man.user_details['username']}'s moderation revoked."
          end
        else
          # puts 'User not in target group'
        end
      end
      
    end

    # check if group moves  happened ... or ... comment out for no check after update
    def check_users_groups(man, related_group)
      user_details_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])
      @mock ? sleep(0) : sleep(1)
      related_group_found = false
      user_in_any_owner_group = false
      user_details_after_update['groups'].each do |user_group_after_update|
        if user_group_after_update['id'] == related_group
          @schedule.discourse.options[:logger]
              .warn "#{user_details_after_update['username']} now in Group: #{user_group_after_update['name']}"
          related_group_found = true
          if @options[:settings][:all_ownership_group_ids].include?(user_group_after_update['id'])
            user_in_any_owner_group = true
          end
        end
      end
      if related_group_found
        # puts 'related_group_found is true'
      else
        @schedule.discourse.options[:logger].warn "#{user_details_after_update['username']} not currently not in #{related_group} Ownership group."
      end
      user_in_any_owner_group
    end

    def message_path
      File.expand_path("../../../../ownership/messages", __FILE__)
    end

    def message_body(text_file)
      File.read(message_path + '/' + text_file)
    end

    def zero_notifications_counters
      counters[:'Ownership']                  =   0
      counters[:'Ownership Targets']          =   0
      counters[:'Ownership Updated']          =   0
      counters[:'Messages Sent']              =   0
      counters[:'Users Added to Group']       =   0
      counters[:'Users Removed from Group']   =   0
    end

  end
end
