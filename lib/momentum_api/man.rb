$LOAD_PATH.unshift File.expand_path('../../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../../discourse_api/lib/discourse_api', __FILE__)
require_relative '../momentum_api/api/notification'
require_relative '../momentum_api/api/user'

module MomentumApi
  class Man
    # attr_accessor :do_live_updates
    attr_reader :user_client, :user_details, :discourse

    include MomentumApi::Notification
    include MomentumApi::User

    def initialize(user_client, user_details, users_categories=nil)
      raise ArgumentError, 'user_client needs to be defined' if user_client.nil?
      raise ArgumentError, 'user_details needs to be defined' if user_details.nil? || user_details.empty?

      # messages
      @emails_from_username =   'Kim_Miller'

      # parameter setting
      @user_client          =   user_client
      @user_details         =   user_details
      @users_categories     =   users_categories

      # testing parameters
      @issue_users        =     %w()
      
    end

    def run_scans(discourse)
      @discourse = discourse
      users_groups = @user_details['groups']

      is_owner = false
      if @discourse.issue_users.include?(@user_details['username'])
        puts "#{@user_details['username']} in apply_function"
      end

      # Examine Users Groups
      users_groups.each do |group|
        group_name = group['name']

        if @discourse.issue_users.include?(@user_details['username'])
          puts "\n#{@user_details['username']}  with group: #{group_name}\n"
        end

        if @users_categories
          category_cases(group_name)
        else
          puts "\nSkipping Category Cases for #{@user_details['username']}.\n"
        end

        # Group Cases (make a method)
        case
        when group_name == 'Owner'
          is_owner = true
        else
          # puts 'No Group Case'
        end
      end

      # Update Trust Level
      if @discourse.scan_options['trust_level_updates'.to_sym]
        self.update_user_trust_level(discourse, is_owner, 0, @user_details)
      end

      # Update User Group Alias Notification
      if @discourse.scan_options['user_group_alias_notify'.to_sym]
        self.user_group_notify_to_default
      end

      # User Scoring
      if @discourse.scan_options['score_user_levels'.to_sym]
        puts @discourse.scan_options['score_user_levels']
        @discourse.user_score_poll.run_scans(self)
      end
    end

    def category_cases(group_name)
      starting_categories_updated = @discourse.categories_updated

      @users_categories.each do |category|

        if @discourse.issue_users.include?(@user_details['username'])
          puts "\n#{@user_details['username']}  Category case on category: #{category['slug']}\n"
        end

        case
        when category['slug'] == group_name
          case_excludes = %w(Steve_Scott)
          if case_excludes.include?(@user_details['username'])
            # puts "#{@user_details['username']} specifically excluded from Watching Meta"
          else
            if @discourse.scan_options['team_category_watching'.to_sym]    # todo simplify signature
              self.set_category_notification(category, group_name, [3], 3)
            end
          end

        when (category['slug'] == 'Essential' and group_name == 'Owner')
          case_excludes = %w(Steve_Scott)
          if case_excludes.include?(@user_details['username'])
            # puts "#{@user_details['username']} specifically excluded from Essential Watching"
          else                            # 4 = Watching first post, 3 = Watching, 1 = blank or ...?
            if @discourse.scan_options['essential_watching'.to_sym]
              self.set_category_notification(category, group_name, [3], 3)
            end
          end

        when (category['slug'] == 'Growth' and group_name == 'Owner')
          case_excludes = %w(Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
          if case_excludes.include?(@user_details['username'])
            # puts "#{@user_details['username']} specifically excluded from Watching Growth"
          else
            if @discourse.scan_options['growth_first_post'.to_sym]
              self.set_category_notification(category, group_name, [3, 4], 4)
            end
          end

        when (category['slug'] == 'Meta' and group_name == 'Owner')
          case_excludes = %w(Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
          if case_excludes.include?(@user_details['username'])
            # puts "#{@user_details['username']} specifically excluded from Watching Meta"
          else
            if @discourse.scan_options['meta_first_post'.to_sym]
              self.set_category_notification(category, group_name, [3, 4], 4)
            end
          end

        else
          # puts 'Category not a target'
        end
      end
      if @discourse.categories_updated > starting_categories_updated
        @discourse.users_updated += 1
      end
    end

    def print_user_options(user_details, user_option_print, user_label='UserName', pos_5=user_details[user_option_print[5].to_s])

      field_settings = "%-18s %-14s %-16s %-12s %-12s %-17s %-14s\n"

      printf field_settings, user_label,
             user_option_print[0], user_option_print[1], user_option_print[2],
             user_option_print[3], user_option_print[4], user_option_print[5]

      printf field_settings, user_details['username'],
             user_details[user_option_print[0].to_s].to_s[0..9], user_details[user_option_print[1].to_s].to_s[0..9],
             user_details[user_option_print[2].to_s], user_details[user_option_print[3].to_s],
             user_details[user_option_print[4].to_s], pos_5
    end
    
  end
end
