module MomentumApi
  class DowngradeTrust

    attr_accessor :counters

    def initialize(schedule, user_options, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'options needs to be defined' if user_options.nil? or user_options.empty?

      # parameter setting
      @schedule               =   schedule
      @options                =   user_options[:downgrade_non_owner_trust]
      @mock                   =   mock

      # counter init
      @counters               =   {'Downgrade Trust': ''}
      schedule.discourse.scan_pass_counters << @counters

      zero_notifications_counters

    end

    def run(man)

      if man.is_owner
        # puts "#{man.user_details['username']} is an owner."

      else
        # user_option_print = %w(last_seen_at last_posted_at post_count time_read recent_time_read trust_level)

        # puts 'update_trust_level'
        if @schedule.discourse.options[:issue_users].include?(man.user_details['username'])
          puts "#{man.user_details['username']} in downgrade_trust_level"
        end

        # what to update
        if man.user_details['trust_level'] == @options[:allowed_levels]
          # man.print_user_options(man.user_details, user_option_print, 'Correct Trust')
        else
          man.print_user_options(man.user_details, user_label: 'Non Owner', pos_5: 'trust_level')
          @counters[:'User Trust Targets'] += 1
          # puts 'User to be updated'

          if @schedule.discourse.options[:do_live_updates] and @options[:do_task_update]

            update_response = @schedule.discourse.admin_client.update_trust_level(
                man.user_details['id'], level: @options[:set_level])
            man.discourse.options[:logger].warn "#{update_response['admin_user']['username']} Downgraded"
            @counters[:'User Trust Updated'] += 1

            # check if update happened
            user_details_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])
            man.print_user_options(user_details_after_update, user_label: 'Non Owner', pos_5: 'trust_level')
            @mock ? sleep(0) : sleep(1)
          end
        end
      end

    end

    def zero_notifications_counters
      counters[:'Users']                    =   0
      counters[:'User Trust Targets']       =   0
      counters[:'User Trust Updated']       =   0
    end

  end
end
