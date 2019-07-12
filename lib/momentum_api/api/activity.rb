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

      if man.user_details['post_count'] > 0 and man.user_details['time_read'] < (60 * 60)
        @counters[:'User Activity'] += 1

        @options.each do |option|
          counters[option[0]] += man.user_details[option[0].to_s]
        end

        read_post_ratio = nil
        if @options[:time_read] and @options[:post_count]
          read_post_ratio = (man.user_details['time_read'] / 60) / man.user_details['post_count']
          
          if counters[:post_count] > 0
            counters[:'Read-Post Ratio'] = (counters[:time_read] / 60) / counters[:post_count]
          end
        end

        man.print_user_options(man.user_details, user_label: 'Momentum Man Activity', user_field: 'profile_view_count',
                               hash: {'Read-Post Ratio': read_post_ratio})
      end

        # @counters[:'Category Update Targets'] += 1
        # if @schedule.discourse.options[:do_live_updates]
        #   update_response = man.user_client.category_set_user_notification(id: category['id'], notification_level: levels[:set_level])
        #   @mock ? sleep(0) : sleep(1)
        #   man.discourse.options[:logger].warn update_response
        #   @counters[:'Category Notify Updated'] += 1
        #
        #   # check if update happened ... or ... comment out for no check after update
        #   user_details_after_update = man.user_client.categories
        #   @mock ? sleep(0) : sleep(1)
        #   user_details_after_update.each do |users_category_second_pass|
        #     new_category_slug = users_category_second_pass['slug']
        #     if category['slug'] == new_category_slug
        #       man.discourse.options[:logger].warn "Updated Category: #{new_category_slug}    Notification Level: #{users_category_second_pass['notification_level']}"
        #     end
        #   end
        # end
      # else
      #   if @schedule.discourse.options[:issue_users].include?(man.user_details['username'])
      #     puts "#{man.user_details['username']} already Watching"
      #   end
      # end
    end

    private

    def zero_notifications_counters
      counters[:'User Activity']    =   0
      @options.each do |option|
        counters[option[0]]         =   0
      end
      # counters[:'Category Update Targets']  =   0
      # counters[:'Category Notify Updated']  =   0
    end

  end
end
