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

      @options.each do |field|

        has_children = (man.user_details[field[0].to_s].class == Hash or man.user_details[field[0].to_s].class == Array)

        if has_children
          field_update(man, field)
        else
          field_update(man, field)
        end

      end

    end

    private

    def zero_notifications_counters
      counters[:'User Preferences']             =   0
      counters[:'User Preference Targets']      =   0
      counters[:'User Preference Updated']      =   0
    end

    def field_update(man, field)
      field_s = field[0].to_s
      user_option_print = %w(last_seen_at last_posted_at post_count time_read recent_time_read)

      if @schedule.discourse.options[:issue_users].include?(man.user_details['username'])
        puts "#{man.user_details['username']} in Preferences"
      end

      # what to update
      if man.user_details['user_option'][field_s] == field[1][:allowed_levels]
        # man.print_user_options(man.user_details, user_option_print, 'Correct Preference')
      else
        man.print_user_options(man.user_details, user_option_print, 'Updated User', user_option: field_s)
        @counters[:'User Preference Targets'] += 1
        # puts 'User to be updated'

        if @schedule.discourse.options[:do_live_updates] and field[1][:do_task_update]

          update_response = @schedule.discourse.admin_client.update_user(man.user_details['username'],
                                                                         "#{field[0]}": field[1][:set_level])
          man.discourse.options[:logger].warn "#{update_response[:body]['success']}"
          @counters[:'User Preference Updated'] += 1

          # check if update happened
          user_option_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])
          man.print_user_options(user_option_after_update, user_option_print, 'Updated User', user_option: field_s)
          @mock ? sleep(0) : sleep(1)

        end
      end
    end

  end
end
