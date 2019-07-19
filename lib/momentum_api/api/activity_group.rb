module MomentumApi
  class ActivityGroup

    attr_accessor :counters

    def initialize(schedule, activity_options, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'options needs to be defined' if activity_options.nil? or activity_options.empty?

      # parameter setting
      @schedule               =   schedule
      @options                =   activity_options
      @mock                   =   mock

      # counter init
      @counters               =   {'Activity Groupping': ''}
      schedule.discourse.scan_pass_counters << @counters

      zero_notifications_counters

    end

    def run(man)

      # activity_grouppings = @options
      @counters[:'User Activity Groupping'] += 1

      activity_groups = []
      @options.each do |activity_group|
        activity_groups << activity_group[1][:allowed_levels]
      end

      mans_current_activity_groups = []
      target_activity_groups = nil

      man.user_details['groups'].each do |user_group|
        if activity_groups.include?(user_group['id'])
          mans_current_activity_groups << user_group['id']
        end
      end

      if @options       # Active Users (60 * 60) = 1 hour   recent_time_read = last 60 days

        if @options[:active_user] and
            (man.user_details['time_read'] > 10 * (60 * 60) or man.user_details['recent_time_read'] > 1 * (60 * 60))

          if @options[:active_user][:do_task_update]
            man.print_user_options(man.user_details, user_label: 'Active User')
            target_activity_groups            = [@options[:active_user][:set_level]]
            counters[:'Active User Count']    += 1
          end

        elsif @options[:average_user] and
            (man.user_details['time_read'] > 1 * (60 * 60) or man.user_details['recent_time_read'] > 0.2 * (60 * 60))

          if @options[:average_user][:do_task_update]
            man.print_user_options(man.user_details, user_label: 'Average User')
            target_activity_groups            = [@options[:active_user][:set_level]]
            counters[:'Average User Count']    += 1
          end

        elsif @options[:email_user] and man.user_details['post_count'] > 5

          if @options[:email_user][:do_task_update]
            man.print_user_options(man.user_details, user_label: 'Email User')
            target_activity_groups            = [@options[:email_user][:set_level]]
            counters[:'Email User Count']     += 1
          end

        elsif @options[:inactive_user]

          if @options[:inactive_user][:do_task_update]
            man.print_user_options(man.user_details, user_label: 'Inactive User')
            target_activity_groups            = [@options[:inactive_user][:set_level]]
            counters[:'Inactive User Count']     += 1
          end

        end
      end

      if man.user_details['time_read'] < (30 * 60)

        read_post_ratio = nil
        if @options[:activity_groupping] and @options[:post_count] and man.user_details['post_count'] > 0
          read_post_ratio = (man.user_details['time_read'] / 60) / man.user_details['post_count']
          
        end

      end

      if @schedule.discourse.options[:do_live_updates] and target_activity_groups and
          target_activity_groups != mans_current_activity_groups

        if mans_current_activity_groups.empty?
          puts 'Man in none of these groups'
        else
          mans_current_activity_groups.each do |current_group_id|
            remove_response = @schedule.discourse.admin_client.group_remove(current_group_id, username: man.user_details['username'])
            @mock ? sleep(0) : sleep(1)
            man.discourse.options[:logger].warn "Removed man: #{remove_response.body['success']}"
            @counters[:'User Removed from Group'] += 1
          end
        end

        update_response = @schedule.discourse.admin_client.group_add(target_activity_groups[0], username: man.user_details['username'])
        @mock ? sleep(0) : sleep(1)
        man.discourse.options[:logger].warn update_response.body['success']
        @counters[:'User Group Updated'] += 1

        # check if update happened ... or ... comment out for no check after update
        user_details_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])
        @mock ? sleep(0) : sleep(1)
        user_details_after_update['groups'].each do |user_group_after_update|
          if user_group_after_update['id'] == target_activity_groups[0]
            man.discourse.options[:logger].warn "#{user_details_after_update['username']} added to: #{user_group_after_update['name']}"
          end
        end
      end

      counters[:time_read]          += man.user_details['time_read']
      counters[:'time_read Count']  += 1

    end

    private

    def zero_notifications_counters
      counters[:'User Activity Groupping']                  =   0
      counters[:time_read]                                  =   0
      counters[:'time_read Count']                          =   0
      counters[:'Active User Count']                        =   0
      counters[:'Average User Count']                       =   0
      counters[:'Email User Count']                         =   0
      counters[:'Inactive User Count']                      =   0
      counters[:'User Group Updated']                       =   0
      counters[:'User Removed from Group']                  =   0
      # @options.each do |option|
      #   counters[option[0]]                                 =   0
      #   counters[(option[0].to_s + " Count").to_sym]        =   0
      #   counters[(option[0].to_s + " Updated").to_sym]      =   0
      # end
      # counters[:'Category Update Targets']  =   0
      # counters[:'Category Notify Updated']  =   0
    end

  end
end
