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

      @counters[:'User Activity Groupping'] += 1

      active_user_group = 130

      activity_groups = [active_user_group, nil, nil]
      mans_current_activity_groups = []
      target_activity_groups = nil

      man.user_details['groups'].each do |user_group|
        if activity_groups.include?(user_group['id'])
          mans_current_activity_groups << user_group['id']
        end
      end

      if @options[:activity_groupping]       # Active Users (60 * 60) = 1 hour   recent_time_read = last 60 days
        if man.user_details['time_read'] > 12 * (60 * 60) or man.user_details['recent_time_read'] > 0.5 * (60 * 60)
          target_activity_groups        = [active_user_group]

          man.print_user_options(man.user_details, user_label: 'Active User')

          counters[:time_read]          += man.user_details['time_read']
          counters[:'time_read Count']  += 1
          counters[:'Active User']      += 1

        elsif false
          # active email user
        else
          # inactive user
        end
      end

      if man.user_details['time_read'] < (30 * 60)

        read_post_ratio = nil
        if @options[:activity_groupping] and @options[:post_count] and man.user_details['post_count'] > 0
          read_post_ratio = (man.user_details['time_read'] / 60) / man.user_details['post_count']
          
        end

      end

      if @schedule.discourse.options[:do_live_updates] and
          @options[:activity_groupping][:do_task_update] and
          target_activity_groups != mans_current_activity_groups

        update_response = @schedule.discourse.admin_client.group_add(target_activity_groups[0], username: man.user_details['username'])
        @mock ? sleep(0) : sleep(1)
        man.discourse.options[:logger].warn update_response.body['success']
        @counters[:'User Group Updated'] += 1

        # check if update happened ... or ... comment out for no check after update
        user_details_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])
        @mock ? sleep(0) : sleep(1)
        user_details_after_update['groups'].each do |user_group_after_update|
          if user_group_after_update['id'] == active_user_group
            man.discourse.options[:logger].warn "User Added to : #{user_group_after_update['name']}"
          end
        end
      end

    end

    private

    def zero_notifications_counters
      counters[:'User Activity Groupping']                  =   0
      counters[:time_read]                                  =   0
      counters[:'time_read Count']                          =   0
      counters[:'Active User']                              =   0
      counters[:'User Group Updated']                       =   0
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
