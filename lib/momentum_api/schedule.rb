require_relative '../momentum_api/api/user'

module MomentumApi
  class Schedule

    attr_reader :user_client, :discourse, :options

    include MomentumApi::User

    def initialize(discourse, schedule_options, mock: nil)
      raise ArgumentError, 'user_client needs to be defined' if discourse.nil?
      raise ArgumentError, 'schedule_options needs to be defined' if schedule_options.nil? or schedule_options.empty?

      # messages
      @emails_from_username   =   'Kim_Miller'

      # parameter setting
      @discourse              =   discourse
      @options                =   schedule_options

      # queue tasks
      @queue_group_owner      =   []
      if @options[:user_scores]
        @queue_group_owner    <<  ( mock || MomentumApi::Poll.new(self, @options[:user_scores]) )
      end
      if @options[:watching]
        @watch_category       =   ( mock || MomentumApi::WatchCategory.new(self, @options[:watching]) )
        @watch_group          =   ( mock || MomentumApi::WatchGroup.new(self, @options[:watching]) )
      end

    end

    def group_cases(man, group)
      if @discourse.options[:issue_users].include?(man.user_details['username'])
        puts "#{man.user_details['username']} in group_cases"
      end

      # for all groups
      # if @options[:watching][:group_alias][:excludes].include?(man.user_details['username'])
      #   # puts "#{man.user_details['username']} specifically excluded from Watching Meta"
      # else
      #   if @options[:watching][:group_alias]
      #     @watch_group.run(man, group_name, @options[:watching][:group_alias])
      #   end
      # end

      @watch_group.run(man, group)

      # for certain groups
      case
      when group['name'] == 'Owner'

        # Owner checking
        man.is_owner = true

        # Owner Tasks e.g. User Scoring
        if @queue_group_owner.any?
          @queue_group_owner.each do |owner_task|
            owner_task.run(man)
          end
        end

      when group['name'] == 'trust_level_1'

        # if @options[:watching] and @options[:watching][:group_alias]
        #   @watch_category.user_group_notify_to_default(man)
        # end

        if @options[:trust_level_updates]
          downgrade_non_owner_trust(man)
        end

      when group['name'] == 'trust_level_0'

        # add upgrade_owner_trust_level 

      else
        # puts 'No Group Case'
      end
    end

    def category_cases(man, group_name)  
      starting_categories_updated = @watch_category.counters[:'Category Notify Updated']

      man.users_categories.each do |category|

        if @discourse.options[:issue_users].include?(man.user_details['username'])
          puts "\n#{man.user_details['username']} Category case on category: #{category['slug']}\n"
        end

        case
        when (category['slug'] == group_name and @options[:watching][:matching_team])
          # case_excludes = %w(Steve_Scott Ryan_Hyer David_Kirk)
          if @options[:watching][:matching_team][:excludes].include?(man.user_details['username'])
            # puts "#{man.user_details['username']} specifically excluded from Watching Meta"
          else
            # if @options[:watching][:matching_team]
              @watch_category.run(man, category, group_name, @options[:watching][:matching_team])
            # end
          end

        when (category['slug'] == 'Essential' and group_name == 'Owner' and @options[:watching][:essential])
          # case_excludes = %w(Steve_Scott Joe_Sabolefski)
          if @options[:watching][:essential][:excludes].include?(man.user_details['username'])
            # puts "#{man.user_details['username']} specifically excluded from Essential Watching"
          else                            # 4 = Watching first post, 3 = Watching, 1 = blank or ...?
            # if @options[:watching][:essential]
              @watch_category.run(man, category, group_name, @options[:watching][:essential])
            # end
          end

        when (category['slug'] == 'Growth' and group_name == 'Owner' and @options[:watching][:growth])
          # case_excludes = %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
          if @options[:watching][:growth][:excludes].include?(man.user_details['username'])
            # puts "#{man.user_details['username']} specifically excluded from Watching Growth"
          else
            # if @options[:watching][:growth]  # first_post
              @watch_category.run(man, category, group_name, @options[:watching][:growth])
            # end
          end

        when (category['slug'] == 'Meta' and group_name == 'Owner' and @options[:watching][:meta])
          # case_excludes = %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
          if @options[:watching][:meta][:excludes].include?(man.user_details['username'])
            # puts "#{man.user_details['username']} specifically excluded from Watching Meta"
          else
            # if @options[:watching][:meta]
              @watch_category.run(man, category, group_name, @options[:watching][:meta])
            # end
          end

        else
          # puts 'Category not a target'
        end
      end
      if @watch_category.counters[:'Category Notify Updated'] > starting_categories_updated
        @watch_category.counters[:'Category Notify Updated'] += 1      # todo this logic even correct?
      end
    end

  end
end
