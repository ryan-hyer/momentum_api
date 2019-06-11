module MomentumApi
  class Man

    attr_reader :user_client, :user_details, :users_categories
    attr_accessor :is_owner

    def initialize(discourse, user_client, user_details, mock: nil)
      raise ArgumentError, 'user_client needs to be defined' if user_client.nil?
      raise ArgumentError, 'user_details needs to be defined' if user_details.nil? || user_details.empty?

      @discourse          =   discourse
      @mock               =   mock

      @user_details       =   user_details

      begin
        @users_categories = user_client.categories
        @mock ? sleep(0) : sleep(1)
      rescue DiscourseApi::UnauthenticatedError
        @users_categories = nil
        puts "\n#{user_details['username']} : DiscourseApi::UnauthenticatedError - Not permitted to view resource.\n"
      rescue DiscourseApi::TooManyRequests
        puts 'Sleeping for 20 seconds ....'
        @mock ? sleep(0) : sleep(20)
        @users_categories = user_client.categories
      end

      @is_owner = false

    end


    def scan_contexts

      if @discourse.issue_users.include?(@user_details['username'])
        puts "#{@user_details['username']} in scan_contexts"
      end

      # Examine Users Groups and Cagegories
      @user_details['groups'].each do |group|
        
        if @discourse.issue_users.include?(@user_details['username'])
          puts "\n#{@user_details['username']}  with group: #{group['name']}\n"
        end

        # Group Cases
        @discourse.schedule.group_cases(self, group['name'])

        if @users_categories
          @discourse.schedule.category_cases(@user_details, group['name'], @users_categories)
        else
          puts "\nSkipping Category Cases for #{@user_details['username']}.\n"
        end

      end

      # # Update Trust Level
      if @discourse.schedule.scan_options[:trust_level_updates] and not @is_owner
        @discourse.schedule.update_user_trust_level(@discourse, self, 0)
      end
      
      # # Update User Group Alias Notification
      # if @scan_options['user_group_alias_notify'.to_sym]
      #   self.user_group_notify_to_default
      # end
      #
      # # User Scoring
      # if @scan_options['score_user_levels'.to_sym]
      #   # puts @scan_options['score_user_levels'.to_sym]
      #   @user_score_poll.run_scans(self)
      # end
    end


  end
end
