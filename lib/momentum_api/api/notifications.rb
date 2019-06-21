module MomentumApi
  class Notifications

    attr_accessor :counters

    def initialize(schedule, options: nil, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      # raise ArgumentError, 'options needs to be defined' if options.nil? or options.empty?

      # counter init
      @counters =   {'Notifications': ''}   # todo finish class & tests
      schedule.discourse.scan_pass_counters << @counters

      zero_notifications_counters

    end

    def set_category_notification(man, category, group_name, allowed_levels, set_level)
      if not allowed_levels.include?(category['notification_level'])
        print_user(man, category['slug'], group_name, category['notification_level'],
                   status='NOT Watching', type='CategoryUser')

        @counters[:'Category Update Targets'] += 1
        if @discourse.options[:do_live_updates]
          update_response = man.user_client.category_set_user_notification(id: category['id'], notification_level: set_level)
          sleep 1
          puts update_response
          @counters[:'Category Notify Updated'] += 1

          # check if update happened ... or ... comment out for no check after update
          user_details_after_update = man.user_client.categories
          sleep 1
          user_details_after_update.each do |users_category_second_pass|
            new_category_slug = users_category_second_pass['slug']
            if category['slug'] == new_category_slug
              puts "Updated Category: #{new_category_slug}    Notification Level: #{users_category_second_pass['notification_level']}\n"
            end
          end
        end
      else
        if @discourse.options[:issue_users].include?(man.user_details['username'])
          print_user(man, category['slug'], group_name, category['notification_level'],
                     status='Watching', type='CategoryUser')
        end
      end
      @counters[:'User Categories'] += 1
    end

    def user_group_notify_to_default(man)                 # todo refactor inside discourse group
      users_groups = man.user_details['groups']
      users_groups.each do |group|
        users_group_users = man.user_details['group_users']
        users_group_users.each do |users_group|
          if group['id'] == users_group['group_id']
            @counters[:'User Groups'] += 1
            if users_group['notification_level'] != group['default_notification_level'] # and if group['name'] == @target_group_name    # uncomment for just one group
              print_user(man, 'na', group['name'], users_group['notification_level'],
                         status="NOT Group Default of #{group['default_notification_level']}", type='GroupUser')
              @counters[:'Group Update Targets'] += 1
              if @discourse.options[:do_live_updates]
                response = @discourse.admin_client.group_set_user_notify_level(group['name'], man.user_details['id'], group['default_notification_level'])
                sleep 1
                puts response
                @counters[:'Group Notify Updated'] += 1

                # check if update happened ... or ... comment out for no check after update
                user_details_after_update = @discourse.admin_client.user(man.user_details['username'])['group_users']
                sleep 1
                user_details_after_update.each do |users_group_second_pass| # uncomment to check for the update
                  if users_group_second_pass['group_id'] == users_group['group_id']
                    puts "Updated Group: #{group['name']}    Notification Level: #{users_group_second_pass['notification_level']}    Default: #{group['default_notification_level']}"
                  end
                end
              end
            else
              # printf "%-16s %-20s %-15s %-15s  OK :)\n", man.user_details['username'], group['name'], users_group['notification_level'].to_s.center(15), group['default_notification_level'].to_s.center(15)
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
      counters[:'User Categories']          =   0
      counters[:'User Groups']              =   0
      counters[:'Category Update Targets']  =   0
      counters[:'Group Update Targets']     =   0
      counters[:'Category Notify Updated']  =   0
      counters[:'Group Notify Updated']     =   0
    end


  end
end
