
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
      # is an Owner
      when *@discourse.options[:ownership_groups]
      # when 'Owner', 'Owner_Manual'

        # Set Owner status
        man.is_owner = true
        #
        # # Owner Tasks e.g. User Scoring
        # if @owner_queue.any?
        #   @owner_queue.each do |owner_task|
        #     owner_task.run(man)
        #   end
        # end
        #
        # category_cases(man, is_owner:true)

      when 'trust_level_1'

      when 'trust_level_0'
        
      else
        # puts 'No Group Case'
      end

    end

    def category_cases(man, group:nil, is_owner:nil)
      if @category_queue.any?

        man.users_categories.each do |category|

          @category_queue.each do |category_task|

            if @discourse.options[:issue_users].include? man.user_details['username']
              puts "\n#{man.user_details['username']} Category case on category: #{category['slug']}\n"
            end

            category_task.options.each do |category_action|
              if category_action[1][:excludes].include? man.user_details['username']
               # puts "#{man.user_details['username']} specifically excluded from Watching action"
              else
                case
                when (is_owner and category['slug'] == category_action[0].to_s)
                    category_task.run(man, category, category_action[1])

                when (group and category['slug'] == group['name'] and category_action[0] == :matching_team)
                    category_task.run(man, category, category_action[1], group_name: group['name'])
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

      if man.is_owner

        # Owner Tasks e.g. User Scoring
        if @owner_queue.any?
          @owner_queue.each do |owner_task|
            owner_task.run(man)
          end
        end

        category_cases(man, is_owner:true)

      end
    end

  end
end
