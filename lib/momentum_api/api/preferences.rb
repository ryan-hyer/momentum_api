module MomentumApi
  class Preferences

    attr_accessor :counters

    def initialize(schedule, user_preferences, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'options needs to be defined' if user_preferences.nil? or user_preferences.empty?

      # parameter setting
      @schedule               =   schedule
      @options                =   user_preferences
      @mock                   =   mock

      # counter init
      @counters               =   {'User Preferences': ''}
      schedule.discourse.scan_pass_counters << @counters

      zero_notifications_counters

    end

    def run(man)

      @options.each do |preference_type|

        preference_type[1].each do |preference|

          if preference[1][:excludes].include?(man.user_details['username'])
            # puts "#{man.user_details['username']} is Excluded from this Task."
          else
            target_update_field = nil
            
            case preference_type[0].to_s
            
            when 'user_option'
              # preference_type[1].each do |preference|
              #   if preference[1][:excludes].include?(man.user_details['username'])
                  # puts "#{man.user_details['username']} is Excluded from this Task."
                # else
              target_update_field = preference[0].to_s
                  # if man.user_details[preference_type[0].to_s][target_update_field] == preference[1][:allowed_levels]
                  #   # man.print_user_options(man.user_details, user_option_print, 'Correct Preference')
                  # else
                  #   field_update(man, preference,%W(#{preference_type[0]} #{target_update_field}))
                  # end
                # end
              # end
            when 'user_fields'
              # preference_type[1].each do |preference|
              #   if preference[1][:excludes].include?(man.user_details['username'])
                  # puts "#{man.user_details['username']} is Excluded from this Task."
                # else
              target_update_field = preference[1][:set_level].keys[0].to_s
                  # if man.user_details[preference_type[0].to_s][target_update_field] == preference[1][:allowed_levels]
                  #   # man.print_user_options(man.user_details, user_option_print, 'Correct Preference')
                  # else
                  #   field_update(man, preference,%W(#{preference_type[0]} #{target_update_field}))
                  # end
                # end
              # end
            else
              # field_update(man, preference_option)
            end

            if man.user_details[preference_type[0].to_s][target_update_field] == preference[1][:allowed_levels]
              # man.print_user_options(man.user_details, user_option_print, 'Correct Preference')
            else
              field_update(man, preference,%W(#{preference_type[0]} #{target_update_field}))
            end


          end
        end

      end

    end

    private

    def field_update(man, preference, updated_option)

      if @schedule.discourse.options[:issue_users].include?(man.user_details['username'])
        puts "#{man.user_details['username']} in Preferences"
      end

      # user_option_print = %w(last_seen_at last_posted_at post_count time_read recent_time_read)
      man.print_user_options(man.user_details, user_label: 'User to be Updated', nested_user_field: updated_option)
      @counters[:'User Preference Targets'] += 1
      # puts 'User to be updated'
      # puts find_set_level(man, preference)
      if @schedule.discourse.options[:do_live_updates] and preference[1][:do_task_update]

        update_response = @schedule.discourse.admin_client.update_user(man.user_details['username'],
                                                                       "#{preference[0]}": find_set_level(man, preference))
        man.discourse.options[:logger].warn "#{update_response[:body]['success']}"
        @counters[:'User Preference Updated'] += 1

        # check if update happened
        user_option_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])
        man.print_user_options(user_option_after_update, user_label: 'User to be Updated', nested_user_field: updated_option)
        @mock ? sleep(0) : sleep(1)

      end
      # end
    end

    def find_set_level(man, preference)
      # if true
      hashback = nil
      if preference[1][:set_level].is_a? Hash and preference[1][:set_level].values[0].respond_to? :each
        sso_user = @schedule.discourse.admin_client.user_sso(man.user_details['user_option']['user_id'])
        preference[1][:set_level].values[0].each do |row|
          # todo add .respond_to? :Email
          if row['Email'] == sso_user['external_email']
            # key_s = preference[1][:set_level].keys[0].to_s
            # {key_s: 1}
            hashback = {"#{preference[1][:set_level].keys[0]}": row['Expiration date']}
          end
        end
        hashback
      else
        preference[1][:set_level]
        puts 'not here'
      end
    end

    def zero_notifications_counters
      counters[:'User Preferences']             =   0
      counters[:'User Preference Targets']      =   0
      counters[:'User Preference Updated']      =   0
    end

  end
end
