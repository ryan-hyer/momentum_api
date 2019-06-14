# $LOAD_PATH.unshift File.expand_path('../../../../discourse_api/lib', __FILE__)
# require File.expand_path('../../../../discourse_api/lib/discourse_api', __FILE__)
require_relative '../momentum_api/api/notification'
require_relative '../momentum_api/api/user'

module MomentumApi
  class Schedule

    attr_reader :user_client, :discourse, :schedule_options

    include MomentumApi::Notification
    include MomentumApi::User

    def initialize(discourse, schedule_options, mock: nil)
      raise ArgumentError, 'user_client needs to be defined' if discourse.nil?
      raise ArgumentError, 'schedule_options needs to be defined' if schedule_options.nil? or schedule_options.empty?

      # messages
      @emails_from_username   =   'Kim_Miller'

      # parameter setting
      @discourse              =   discourse
      @schedule_options       =   schedule_options

      @queue_group_owner      =   []
      if @schedule_options[:score_user_levels]
        @queue_group_owner    <<  ( mock || MomentumApi::Poll.new(self, @schedule_options[:score_user_levels]) )
      end

      # counter init
      @notifications_counters =   {'Notifications': ''}   # todo notificatons class
      @discourse.scan_pass_counters << @notifications_counters

      zero_notifications_counters

    end

    def group_cases(man, group_name)
      if @discourse.options[:issue_users].include?(man.user_details['username'])
        puts "#{man.user_details['username']} in group_cases"
      end

      case
      when group_name == 'Owner'

        # Owner checking
        man.is_owner = true

        # Owner Tasks
        if @queue_group_owner.any?
          @queue_group_owner.each do |owner_task|
            owner_task.run(man)
          end
        end

        # User Scoring
        if @schedule_options[:score_user_levels]
          # puts @scan_options['score_user_levels'.to_sym]
          # @user_score_poll.run(man)
        end

      when group_name == 'trust_level_1'

        if @schedule_options[:user_group_alias_notify]
          self.user_group_notify_to_default(man)
        end

        if @schedule_options[:trust_level_updates]
          downgrade_non_owner_trust(man)
        end

      when group_name == 'trust_level_0'

        # add upgrade_owner_trust_level 

      else
        # puts 'No Group Case'
      end
    end

    def category_cases(man, group_name)       # todo refactor to Class
      starting_categories_updated = @notifications_counters[:'Category Notify Updated']

      man.users_categories.each do |category|

        if @discourse.options[:issue_users].include?(man.user_details['username'])
          puts "\n#{man.user_details['username']}  Category case on category: #{category['slug']}\n"
        end

        case
        when category['slug'] == group_name
          case_excludes = %w(Steve_Scott Ryan_Hyer David_Kirk)
          if case_excludes.include?(man.user_details['username'])
            # puts "#{man.user_details['username']} specifically excluded from Watching Meta"
          else
            if @schedule_options[:team_category_watching]    # todo simplify signature
              self.set_category_notification(man, category, group_name, [3], 3)
            end
          end

        when (category['slug'] == 'Essential' and group_name == 'Owner')
          case_excludes = %w(Steve_Scott Joe_Sabolefski)
          if case_excludes.include?(man.user_details['username'])
            # puts "#{man.user_details['username']} specifically excluded from Essential Watching"
          else                            # 4 = Watching first post, 3 = Watching, 1 = blank or ...?
            if @schedule_options[:essential_watching]
              self.set_category_notification(man, category, group_name, [3], 3)
            end
          end

        when (category['slug'] == 'Growth' and group_name == 'Owner')
          case_excludes = %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
          if case_excludes.include?(man.user_details['username'])
            # puts "#{man.user_details['username']} specifically excluded from Watching Growth"
          else
            if @schedule_options[:growth_first_post]
              self.set_category_notification(man, category, group_name, [3, 4], 4)
            end
          end

        when (category['slug'] == 'Meta' and group_name == 'Owner')
          case_excludes = %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
          if case_excludes.include?(man.user_details['username'])
            # puts "#{man.user_details['username']} specifically excluded from Watching Meta"
          else
            if @schedule_options[:meta_first_post]
              self.set_category_notification(man, category, group_name, [3, 4], 4)
            end
          end

        else
          # puts 'Category not a target'
        end
      end
      if @notifications_counters[:'Category Notify Updated'] > starting_categories_updated
        @notifications_counters[:'Category Notify Updated'] += 1
      end
    end

    # def print_user_options(user_details, user_option_print, user_label='UserName', pos_5=user_details[user_option_print[5].to_s])
    #
    #   field_settings = "%-18s %-14s %-16s %-12s %-12s %-17s %-14s\n"
    #
    #   printf field_settings, user_label,
    #          user_option_print[0], user_option_print[1], user_option_print[2],
    #          user_option_print[3], user_option_print[4], user_option_print[5]
    #
    #   printf field_settings, user_details['username'],
    #          user_details[user_option_print[0].to_s].to_s[0..9], user_details[user_option_print[1].to_s].to_s[0..9],
    #          user_details[user_option_print[2].to_s], user_details[user_option_print[3].to_s],
    #          user_details[user_option_print[4].to_s], pos_5
    # end

    def zero_notifications_counters
      @notifications_counters[:'User Categories']         =   0
      @notifications_counters[:'User Groups']          =   0
      @notifications_counters[:'Category Update Targets']      =   0
      @notifications_counters[:'Group Update Targets']      =   0
      @notifications_counters[:'Category Notify Updated']      =   0
      @notifications_counters[:'Group Notify Updated']      =   0
    end

  end
end
