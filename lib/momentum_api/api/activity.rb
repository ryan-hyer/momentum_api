module MomentumApi
  class Activity

    attr_accessor :counters

    def initialize(schedule, activity_options, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'options needs to be defined' if activity_options.nil? or activity_options.empty?

      # parameter setting
      @schedule               =   schedule
      @options                =   activity_options
      @mock                   =   mock

      # counter init
      @counters               =   {'Activity': ''}
      schedule.discourse.scan_pass_counters << @counters

      zero_notifications_counters

    end

    def run(man)

      @counters[:'User Activity'] += 1

      if @options[:time_read]       # Active Users (60 * 60) = 1 hour   recent_time_read = last 60 days
        if man.user_details['time_read'] > 12 * (60 * 60) or man.user_details['recent_time_read'] > 0.5 * (60 * 60)
          man.print_user_options(man.user_details, user_label: 'Read Time Groupping')

          counters[:time_read] += man.user_details['time_read']
          counters[:'time_read Count'] += 1

          active_user_group = 130
          is_a_member = false

          man.user_details['groups'].each do |user_group|
            if user_group['id'] == active_user_group
              is_a_member = true
              puts 'already a member'
            end
          end

          if @schedule.discourse.options[:do_live_updates] and @options[:time_read][:do_task_update] and not is_a_member
            update_response = @schedule.discourse.admin_client.group_add(active_user_group, username: man.user_details['username'])
            @mock ? sleep(0) : sleep(1)
            man.discourse.options[:logger].warn update_response.body['success']
            @counters[:'time_read Updated'] += 1

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
      end
      # if man.user_details['post_count'] > 0 and man.user_details['time_read'] < (60 * 60)
      if man.user_details['time_read'] < (30 * 60)

        read_post_ratio = nil
        if @options[:time_read] and @options[:post_count] and man.user_details['post_count'] > 0
          read_post_ratio = (man.user_details['time_read'] / 60) / man.user_details['post_count']
          
        end

        # man.print_user_options(man.user_details, user_label: 'Momentum Man Activity', user_field: 'profile_view_count',
        #                        hash: {'Read-Post Ratio': read_post_ratio})

        # @options.each do |option|
        #   counters[option[0]] += man.user_details[option[0].to_s]
        # end

        # if counters[:post_count] > 0
        #   counters[:'Read-Post Ratio'] = (counters[:time_read] / 60) / counters[:post_count]
        # end

      end

        # @counters[:'Category Update Targets'] += 1

      # else
      #   if @schedule.discourse.options[:issue_users].include?(man.user_details['username'])
      #     puts "#{man.user_details['username']} already Watching"
      #   end
      # end
    end

    private

    def zero_notifications_counters
      counters[:'User Activity']                            =   0
      @options.each do |option|
        counters[option[0]]                                 =   0
        counters[(option[0].to_s + " Count").to_sym]        =   0
        counters[(option[0].to_s + " Updated").to_sym]      =   0
      end
      # counters[:'Category Update Targets']  =   0
      # counters[:'Category Notify Updated']  =   0
    end

  end
end
