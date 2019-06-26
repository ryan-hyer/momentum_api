module MomentumApi
  class WatchGroup

    attr_accessor :counters

    def initialize(schedule, group_options, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'options needs to be defined' if group_options.nil? or group_options.empty?

      # parameter setting
      @schedule               =   schedule
      @options                =   group_options[:group_alias]
      @mock                   =   mock

      # counter init
      @counters               =   {'Watch Groups': ''}
      schedule.discourse.scan_pass_counters << @counters

      zero_notifications_counters

    end

    def run(man, group) 
      if @options and not @options[:excludes].include?(man.user_details['username'])
        users_group_users = man.user_details['group_users']
        users_group_users.each do |users_group|
          if group['id'] == users_group['group_id']
            @counters[:'User Groups'] += 1
            allowed_levels   = @options[:allowed_levels] || [group['default_notification_level']]
            set_notification_level   = @options[:set_level] || group['default_notification_level']

            # if users_group['notification_level'] != group['default_notification_level'] # and if group['name'] == @target_group_name    # uncomment for just one group
            if allowed_levels.include?(users_group['notification_level'])
              if @schedule.discourse.options[:issue_users].include?(man.user_details['username'])
                puts "#{man.user_details['username']} already Watching"
              end
              # printf "%-16s %-20s %-15s %-15s  OK :)\n", man.user_details['username'], group['name'], users_group['notification_level'].to_s.center(15), group['default_notification_level'].to_s.center(15)
            else
              print_user(man, 'na', group['name'], users_group['notification_level'],
                         status="NOT Group Default of #{group['default_notification_level']}", type='GroupUser')
              @counters[:'Group Update Targets'] += 1

              if @schedule.discourse.options[:do_live_updates]
                response = @schedule.discourse.admin_client.group_set_user_notify_level(group['name'], man.user_details['id'], set_notification_level)
                @mock ? sleep(0) : sleep(1)
                puts response
                @counters[:'Group Notify Updated'] += 1

                # check if update happened ... or ... comment out for no check after update
                user_details_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])['group_users']
                @mock ? sleep(0) : sleep(1)
                user_details_after_update.each do |users_group_second_pass| # uncomment to check for the update
                  if users_group_second_pass['group_id'] == users_group['group_id']
                    puts "Updated Group: #{group['name']}    Notification Level: #{users_group_second_pass['notification_level']}    Set Level: #{set_notification_level}"
                  end
                end
              end
            # else
              # printf "%-16s %-20s %-15s %-15s  OK :)\n", man.user_details['username'], group['name'], users_group['notification_level'].to_s.center(15), set_notification_level.to_s.center(15)
            end
          end
        end
      end
    end

    def print_user(man, category_slug, group_name, notify_level, status='', type='UserName')
      field_settings = "%-18s %-20s %-20s %-10s %-30s\n"
      printf field_settings, type, 'Group', 'Category', 'Level', 'Status'
      printf field_settings, man.user_details['username'], group_name, category_slug, notify_level.to_s.center(5), status
    end

    def zero_notifications_counters
      counters[:'User Groups']              =   0
      counters[:'Group Update Targets']     =   0
      counters[:'Group Notify Updated']     =   0
    end


  end
end
