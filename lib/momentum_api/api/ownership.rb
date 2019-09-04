module MomentumApi
  class Ownership

    attr_accessor :counters

    def initialize(schedule, ownership_options, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'options needs to be defined' if ownership_options.nil? or ownership_options.empty?

      # parameter setting
      @schedule               =   schedule
      @options                =   ownership_options
      @mock                   =   mock

      @message_client         =   mock || MomentumApi::Messages.new(self, 'Kim_Miller')

      # counter init
      @counters               =   {'Ownership': ''}
      schedule.discourse.scan_pass_counters << @counters

      zero_notifications_counters

    end

    def run(man)

      clock = @mock || Date

      @options.each do |ownership_type|
        ownership_type[1].each do |action|
          renews_value = man.user_details['user_fields'][action[1][:renews_field]]
          if action[1][:excludes].include?(man.user_details['username'])
            # puts "#{man.user_details['username']} is Excluded from this Task."
          elsif renews_value  and
              Date.valid_date?(renews_value[0..3].to_i, renews_value[5..6].to_i, renews_value[8..9].to_i)

            renew_ownership_code = renews_value[11..12]
            action_ownership_code_match = renew_ownership_code == action[1][:ownership_code]

            renew_date = Date.parse(renews_value[0..9])
            action_date_qualifies = clock.today >= renew_date - action[1][:days_until_renews]

            if action_date_qualifies and action_ownership_code_match
              
              case ownership_type[0].to_s

              when 'manual'

                if renews_value[14] == 'R' and renews_value[15] =~ /^\d+$/

                  action_sequence_last = renews_value[15].to_i
                  action_sequence_qualifies = action_sequence_last + 1 == action[1][:action_sequence][1].to_i

                  if action_sequence_qualifies

                    send_renewal_message(renew_ownership_code, action_sequence_last)
                    # todo 1. update renews_value with R code or 2.
                    # puts Date.today.strftime("%Y-%m-%d")
                    puts ownership_type[0].to_s
                    puts action[1][:days_until_renews]
                    puts action_date_qualifies
                    puts renew_date
                    puts action_sequence_qualifies
                    
                  end
                else
                  puts 'Needs R value set'  # todo set R value to R0
                end
                
              when 'auto'

              else
                puts 'No recognized ownership_type'
              end

            end

          elsif renews_value and 
              Date.valid_date?(renews_value[0..3].to_i, renews_value[5..6].to_i, renews_value[8..9].to_i)

            puts 'Adding R value'

          else
            # puts 'Invalid renews_value'
          end
          
        end
      end
    end

    
    private

    def message_path
      File.expand_path("../../../../ownership/messages", __FILE__)
    end

    def message_body(text_file)
      File.read(message_path + '/' + text_file)
    end
    
    def send_renewal_message(renew_ownership_code, action_sequence_last)
      message_file = renew_ownership_code + '_R' + action_sequence_last.to_s + '.txt'
      message_subject = "Thank You for Owning Momentum!"
      message_body = eval(message_body(message_file))
      @message_client.send_private_message(@man, message_body, message_subject)
    end

    def field_update(man, preference, updated_option)

      if @schedule.discourse.options[:issue_users].include?(man.user_details['username'])
        puts "#{man.user_details['username']} in Preferences"
      end

      # user_option_print = %w(last_seen_at last_posted_at post_count time_read recent_time_read)
      man.print_user_options(man.user_details, user_label: 'User to be Updated', nested_user_field: updated_option)
      @counters[:'User Preference Targets'] += 1
      # puts 'User to be updated'

      update_set_value = find_set_value(man, preference)

      if @schedule.discourse.options[:do_live_updates] and preference[1][:do_task_update] and update_set_value

        update_response = @schedule.discourse.admin_client.update_user(man.user_details['username'],
                                                                         "#{preference[0]}": update_set_value)
        man.discourse.options[:logger].warn "#{update_response[:body]['success']}"
        @counters[:'User Preference Updated'] += 1

        # check if update happened
        user_option_after_update = @schedule.discourse.admin_client.user(man.user_details['username'])
        man.print_user_options(user_option_after_update, user_label: 'User After Update', nested_user_field: updated_option)
        @mock ? sleep(0) : sleep(1)

      end
      # end
    end

    def find_set_value(man, preference)
      hashback = nil
      if preference[1][:set_level].is_a? Hash and preference[1][:set_level].values[0].respond_to? :each
        sso_user = @schedule.discourse.admin_client.user_sso(man.user_details['user_option']['user_id'])
        preference[1][:set_level].values[0].each do |row|
          # built for Memberful import; dependent on 'Email' field link
          if row['Email']
            update_watermark = ' MF'
            if row['Email'] == sso_user['external_email']
              hashback = {"#{preference[1][:set_level].keys[0]}": row['Expiration clock'] + update_watermark}
            end
          end
        end
        hashback
      else
        preference[1][:set_level]
      end
    end

    def zero_notifications_counters
      counters[:'Ownership']              =   0
      counters[:'Ownership Targets']      =   0
      counters[:'Ownership Updated']      =   0
    end

  end
end
