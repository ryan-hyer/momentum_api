module MomentumApi
  class Preferences

    attr_accessor :counters

    def initialize(schedule, user_fields, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'options needs to be defined' if user_fields.nil? or user_fields.empty?

      # parameter setting
      @schedule               =   schedule
      @options                =   user_fields
      @mock                   =   mock

      # counter init
      @counters               =   {'User Preferences': ''}
      schedule.discourse.scan_pass_counters << @counters

      zero_notifications_counters

    end

    def run(man)

      # options = @options

      @options.each do |preference_type|
        case
        when preference_type[0].to_s == 'user_option'
          preference_type[1].each do |preference|
            if man.user_details['user_option'][preference[0].to_s] == preference[1][:allowed_levels]
              # man.print_user_options(man.user_details, user_option_print, 'Correct Preference')
            else
              field_update(man, preference)
            end
          end
        when preference_type[0].to_s == 'user_fields'
          preference_type[1].each do |preference|
            # if man.user_details['user_fields'][preference[0].to_s] == preference[1][:allowed_levels]
            if man.user_details[preference[0].to_s] == preference[1][:allowed_levels]
              # man.print_user_options(man.user_details, user_option_print, 'Correct Preference')
            else
              field_update(man, preference)
            end
          end
        else
          # field_update(man, preference_option)
        end
      end

    end

    private

    # def dig_options(man, preference_type, parent: nil)
    #   preference_type.each do |preference_option|
    #
    #     # has_children = man.user_details[preference_option[0].to_s].class == Hash
    #     # array_target = man.user_details[preference_option[0].to_s].class == Array
    #
    #    # if has_children
    #       # case
    #       # when preference_option == 'user_option'
    #       #   # self.dig_options(man, target_field, parent: target_field[0].to_s)
    #       #   preference_target = ['user_option'][preference_option[0].to_s]
    #       #   field_update(man, preference_option, preference_target)
    #       # when preference_option == 'user_fields'
    #       #   field_update(man, parent[])
    #       # else
    #       #   field_update(man, preference_option)
    #       # end
    #    # else
    #    #   ''
    #    # end
    #   end
    # end

    def field_update(man, preference)
      # field_s = preference[0].to_s
      user_option_print = %w(last_seen_at last_posted_at post_count time_read recent_time_read)

      # has_children = man.user_details[preference[0].to_s].class == Hash
      # array_target = man.user_details[preference[0].to_s].class == Array
      
      if @schedule.discourse.options[:issue_users].include?(man.user_details['username'])
        puts "#{man.user_details['username']} in Preferences"
      end

      # what to update
      # if man.user_details['user_option'][field_s] == preference[1][:allowed_levels]
      # if man.user_details['user_option'][field_s] == preference[1][:allowed_levels]
        # man.print_user_options(man.user_details, user_option_print, 'Correct Preference')
      # else
      man.print_user_options(man.user_details, user_option_print, 'Updated User', user_option: preference[0].to_s)
      @counters[:'User Preference Targets'] += 1
      # puts 'User to be updated'

      if @schedule.discourse.options[:do_live_updates] and preference[1][:do_task_update]

        update_response = @schedule.discourse.admin_client.update_user(man.user_details['username'],
                                                                       "#{preference[0]}": preference[1][:set_level])
        man.discourse.options[:logger].warn "#{update_response[:body]['success']}"
        @counters[:'User Preference Updated'] += 1

        # check if update happened
        user_option_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])
        man.print_user_options(user_option_after_update, user_option_print, 'Updated User', user_option: preference[0].to_s)
        @mock ? sleep(0) : sleep(1)

      end
      # end
    end
    
    def zero_notifications_counters
      counters[:'User Preferences']             =   0
      counters[:'User Preference Targets']      =   0
      counters[:'User Preference Updated']      =   0
    end

  end
end
