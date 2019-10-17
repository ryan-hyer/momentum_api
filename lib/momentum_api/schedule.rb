
module MomentumApi
  class Schedule

    attr_reader :user_client, :discourse, :options

    def initialize(discourse, schedule_options, mock: nil)
      raise ArgumentError, 'user_client needs to be defined' if discourse.nil?
      raise ArgumentError, 'schedule_options needs to be defined' if schedule_options.nil? or schedule_options.empty?

      # messages
      @emails_from_username   =   'Kim_Miller'

      # parameter setting
      @discourse              =   discourse
      @options                =   schedule_options

      # queue tasks
      @owner_queue            =   []
      if @options[:user_scores]
        @owner_queue          <<  ( mock || MomentumApi::Poll.new(self, @options[:user_scores]) )
      end
      if @options[:user] and @options[:user][:activity_groupping]
        @owner_queue << (mock || MomentumApi::ActivityGroup.new(self, @options[:user][:activity_groupping]))
      end

      @group_queue            =   []
      if @options[:group]
        @group_queue          <<  ( mock || MomentumApi::WatchGroup.new(self, @options[:group]) )
      end

      @category_queue         =   []
      if @options[:category]
        @category_queue       <<   ( mock || MomentumApi::WatchCategory.new(self, @options[:category]) )
      end

      @user_queue             =   []
      if @options[:user]
        if @options[:user][:downgrade_non_owner_trust]
          @user_queue << (mock || MomentumApi::DowngradeTrust.new(self, @options[:user]))
        end
        if @options[:user][:preferences]
          @user_queue << (mock || MomentumApi::Preferences.new(self, @options[:user][:preferences]))
        end
        if @options[:user][:messages]
          @user_queue << (mock || MomentumApi::MessageSend.new(self, @options[:user][:messages]))
        end
      end

      if @options[:ownership]
        @user_queue << (mock || MomentumApi::Ownership.new(self, @options[:ownership]))
      end

    end

    def group_cases(man, group)
      if @discourse.options[:issue_users].include?(man.user_details['username'])
        puts "#{man.user_details['username']} in group_cases"
      end

      # for all groups
      if @group_queue.any?
        @group_queue.each do |task|
          task.run(man, group)
        end
      end

      # for certain groups
      case group['name']
      when 'Owner', 'Owner_Manual'

        # Set Owner status
        man.is_owner = true

        # Owner Tasks e.g. User Scoring
        if @owner_queue.any?
          @owner_queue.each do |owner_task|
            owner_task.run(man)
          end
        end

      when 'trust_level_1'

      when 'trust_level_0'
        
      else
        # puts 'No Group Case'
      end
    end

    def category_cases(man, group)
      if @category_queue.any?
        group_name = group['name']

        man.users_categories.each do |category|

          @category_queue.each do |category_task|

            if @discourse.options[:issue_users].include?(man.user_details['username'])
              puts "\n#{man.user_details['username']} Category case on category: #{category['slug']}\n"
            end

            # case
            # when (category['slug'] == group_name and @options[:category][:matching_team])
              # if @options[:category][:matching_team][:excludes].include?(man.user_details['username'])
              #   # puts "#{man.user_details['username']} specifically excluded from Watching Meta"
              # else
              #   category_task.run(man, category, group_name, @options[:category][:matching_team])
              # end

            # when (category['slug'] == 'Essential' and group_name == 'Owner' and @options[:category][:Essential])
            #   if @options[:category][:Essential][:excludes].include?(man.user_details['username'])
            #     # puts "#{man.user_details['username']} specifically excluded from Essential Watching"
            #   else                            # 4 = Watching first post, 3 = Watching, 1 = blank or ...?
            #     category_task.run(man, category, group_name, @options[:category][:Essential])
            #   end

            # when (category['slug'] == 'Growth' and group_name == 'Owner' and @options[:category][:Growth])
            #   if @options[:category][:Growth][:excludes].include?(man.user_details['username'])
            #     # puts "#{man.user_details['username']} specifically excluded from Watching Growth"
            #   else
            #     category_task.run(man, category, group_name, @options[:category][:Growth])
            #   end

            # when (category['slug'] == 'Meta' and group_name == 'Owner' and @options[:category][:Meta])
            #   if @options[:category][:Meta][:excludes].include?(man.user_details['username'])
            #     # puts "#{man.user_details['username']} specifically excluded from Watching Meta"
            #   else
            #     category_task.run(man, category, group_name, @options[:category][:Meta])
            #   end

            # else
            #   puts 'Category not a target'
            # end

            category_task.options.each do |category_action|
              if category_action[1][:excludes].include?(man.user_details['username'])
               # puts "#{man.user_details['username']} specifically excluded from Watching action"
              else
                case
                when (category['slug'] == category_action[0].to_s and group_name == 'Owner')
                    category_task.run(man, category, group_name, category_action[1])

                when (category['slug'] == group_name and category_action[0] == :matching_team)
                    category_task.run(man, category, group_name, category_action[1])
                else
                  # puts 'Category not a target'
                end
              end
            end

          end
        end
     end
    end

    def user_cases(man)

      if @user_queue.any?
        @user_queue.each do |task|
          task.run(man)
        end
      end

    end

  end
end
