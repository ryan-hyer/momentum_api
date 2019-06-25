# require_relative '../momentum_api/api/messages'

module MomentumApi
  class Man

    attr_reader :discourse, :user_client, :user_details, :users_categories
    attr_accessor :is_owner

    # include MomentumApi::Messages

    def initialize(discourse, user_client, user_details, mock: nil)
      raise ArgumentError, 'user_client needs to be defined' if user_client.nil?
      raise ArgumentError, 'user_details needs to be defined' if user_details.nil? || user_details.empty?

      @discourse          =   discourse
      @mock               =   mock

      @user_details       =   user_details
      @user_client        =   user_client

      begin
        @users_categories = @user_client.categories
        @mock ? sleep(0) : sleep(1)
      rescue DiscourseApi::UnauthenticatedError
        @users_categories = nil
        puts "\n#{user_details['username']} : DiscourseApi::UnauthenticatedError - Not permitted to view resource.\n"
      rescue DiscourseApi::TooManyRequests
        puts 'Sleeping for 20 seconds ....'
        @mock ? sleep(0) : sleep(20)
        @users_categories = @user_client.categories
      end

      @is_owner = false

    end


    def scan_contexts

      if @discourse.options[:issue_users].include?(@user_details['username'])
        puts "#{@user_details['username']} in scan_contexts"
      end

      # Examine Users Groups and Cagegories
      @user_details['groups'].each do |group|
        
        if @discourse.options[:issue_users].include?(@user_details['username'])
          puts "\n#{@user_details['username']}  with group: #{group['name']}\n"
        end

        # Group Cases
        @discourse.schedule.group_cases(self, group)

        if @users_categories and @discourse.schedule.options[:watching]
          @discourse.schedule.category_cases(self, group)
        else
          # puts "\nSkipping Category Cases for #{@user_details['username']}.\n"
        end

      end

      # # Update Trust Level
      if @discourse.schedule.options[:trust_level_updates] and not @is_owner
        @discourse.schedule.downgrade_non_owner_trust(@discourse, self, 0)
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
