module MomentumApi
  class MessageSend

    attr_accessor :counters

    def initialize(schedule, message_send_options, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'options needs to be defined' if message_send_options.nil? or message_send_options.empty?

      # parameter setting
      @schedule               =   schedule
      @options                =   message_send_options
      @mock                   =   mock

      @message_client = @mock || MomentumApi::Messages.new(self, 'KM_Admin')

      # counter init
      @counters               =   {'Message Send': ''}
      schedule.discourse.scan_pass_counters << @counters

      zero_notifications_counters

    end

    def run(man)

      if @schedule.discourse.options[:issue_users].include?(man.user_details['username'])
        puts "#{man.user_details['username']} in Message Send"
      end

      @man = man

      @options.each do |message|
        # next if message[0] == :settings
        update_action(man, message[1])
      end
    end

    
    private
    
    def send_message(action, variable_hash: nil)
      message_file = action[:message_file].to_s
      message_subject = eval(message_body(message_file + '_subject.txt'))
      message_body = eval(message_body(message_file + '_body.txt'))
      @message_client.send_private_message(@man, message_body, message_subject, from_username: action[:message_from],
                                           to_username: action[:message_to], cc_username: action[:message_cc])
    end

    def update_action(man, action, user_update_value: nil)

      man.print_user_options(man.user_details, user_label: "#{action[:message_name]}")
      @counters[:'Message Send Targets'] += 1

      # update_set_value = {"#{action[:user_fields]}": user_update_value}

      if @schedule.discourse.options[:do_live_updates] and action[:do_task_update]

        # update_response = @schedule.discourse.admin_client.update_user(man.user_details['username'],
        #                                                                user_fields: update_set_value)

        @schedule.discourse.options[:logger].warn "Sending Private Message."
        @counters[:'Message Send Updated'] += 1

        # check if update happened
        # user_details_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])
        # man.print_user_options(user_details_after_update, user_label: 'User After Update',
        #                        nested_user_field: %W(#{'user_fields'} #{action[:user_fields]}))
        # @mock ? sleep(0) : sleep(1)

        # add_to_owner_group(action, man)
        # remove_from_group(action, man)

        send_message(action)

      end
    end

    # def add_to_owner_group(action, man)
    #   if action[:add_to_group]
    #     user_already_in_group = false
    #     man.user_details['groups'].each do |group|
    #       if group['id'] == action[:add_to_group]
    #         user_already_in_group = true
    #       end
    #     end
    #
    #     if user_already_in_group
    #       # puts 'User already in group'
    #     else
    #       update_response = @schedule.discourse.admin_client.group_add(action[:add_to_group],
    #                                                                    username: man.user_details['username'])
    #       @mock ? sleep(0) : sleep(1)
    #       @schedule.discourse.options[:logger].warn "Added man to Group #{action[:add_to_group]}: #{update_response['success']}"
    #       @counters[:'Users Added to Group'] += 1
    #       check_users_groups(man, action[:add_to_group])
    #     end
    #   end
    # end

    # def remove_from_group(action, man)
    #   if action[:remove_from_group] and @schedule.discourse.options[:do_live_updates] and action[:do_task_update]
    #     user_in_target_group = false
    #     man.user_details['groups'].each do |group|
    #       if group['id'] == action[:remove_from_group]
    #         user_in_target_group = true
    #       end
    #     end
    #
    #     if user_in_target_group
    #       remove_response = @schedule.discourse.admin_client.group_remove(action[:remove_from_group],
    #                                                                       username: man.user_details['username'])
    #       @mock ? sleep(0) : sleep(1)
    #       @schedule.discourse.options[:logger].warn "Removed man from Group #{action[:remove_from_group]}: #{remove_response['success']}"
    #       @counters[:'Users Removed from Group'] += 1
    #       user_in_any_owner_group = check_users_groups(man, action[:remove_from_group])
    #       if user_in_any_owner_group
    #         # puts 'User still in an Message Send group'
    #       elsif man.user_details['moderator']
    #         @schedule.discourse.admin_client.revoke_moderation(man.user_details['id'])
    #         @schedule.discourse.options[:logger].warn "#{man.user_details['username']}'s moderation revoked."
    #       end
    #     else
    #       # puts 'User not in target group'
    #     end
    #   end
    #
    # end

    # check if group moves  happened ... or ... comment out for no check after update
    # def check_users_groups(man, related_group)
    #   user_details_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])
    #   @mock ? sleep(0) : sleep(1)
    #   related_group_found = false
    #   user_in_any_owner_group = false
    #   user_details_after_update['groups'].each do |user_group_after_update|
    #     if user_group_after_update['id'] == related_group
    #       @schedule.discourse.options[:logger]
    #           .warn "#{user_details_after_update['username']} now in Group: #{user_group_after_update['name']}"
    #       related_group_found = true
    #       if @options[:settings][:all_ownership_group_ids].include?(user_group_after_update['id'])
    #         user_in_any_owner_group = true
    #       end
    #     end
    #   end
    #   if related_group_found
    #     # puts 'related_group_found is true'
    #   else
    #     @schedule.discourse.options[:logger].warn "#{user_details_after_update['username']} not currently not in #{related_group} Ownership group."
    #   end
    #   user_in_any_owner_group
    # end

    def message_path
      File.expand_path("../../../../user/messages", __FILE__)
    end

    def message_body(text_file)
      File.read(message_path + '/' + text_file)
    end

    def zero_notifications_counters
      counters[:'Message Send']                 =   0
      counters[:'Message Send Targets']         =   0
      counters[:'Message Send Updated']         =   0
      counters[:'Messages Sent']                =   0
      counters[:'Users Added to Group']         =   0
      counters[:'Users Removed from Group']     =   0
    end

  end
end
