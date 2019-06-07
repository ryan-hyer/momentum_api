$LOAD_PATH.unshift File.expand_path('../../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../../discourse_api/lib/discourse_api', __FILE__)
# require_relative '../momentum_api/error'
require_relative '../momentum_api/schedule'
require_relative '../momentum_api/man'
require_relative '../momentum_api/api/messages'

module MomentumApi
  class Discourse
    attr_reader :do_live_updates, :issue_users, :user_score_poll, :scan_pass_counters, :admin_client

    include MomentumApi::Messages

    def initialize(discourse_options, schedule_options, mock: nil)
      raise ArgumentError, 'api_username needs to be defined' if discourse_options.nil? || discourse_options.empty?

      # messages
      @emails_from_username = 'Kim_Miller'

      # parameter setting
      @options              = discourse_options
      # @target_username    = discourse_options[:target_username]
      # @target_groups      = discourse_options[:target_groups]
      # @do_live_updates    = discourse_options[:do_live_updates]
      # @instance           = discourse_options[:instance]
      # @api_username       = discourse_options[:api_username]

      @mock               = mock
      @admin_client       = mock || connect_to_instance(discourse_options[:api_username], discourse_options[:instance])

      # counter init
      @discourse_counters = {'Discourse Men': ''}
      @scan_pass_counters = []
      @scan_pass_counters << @discourse_counters

      # create schedule Class
      @schedule = MomentumApi::Schedule.new(self, schedule_options)

      # testing variables
      @exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin)
      @issue_users        = %w()

      zero_discourse_counters

    end

    def connect_to_instance(api_username, instance=@options[:instance])
      client = ''
      case instance
      when 'live'
        client = DiscourseApi::Client.new('https://discourse.gomomentum.org/')
        client.api_key = ENV['REMOTE_DISCOURSE_API']
      when 'local'
        client = DiscourseApi::Client.new('http://localhost:3000')
        client.api_key = ENV['LOCAL_DISCOURSE_API']
      else
        raise 'Host unknown error has occured'
        # raise MomentumError::NotFoundError 'Host unknown error has occured'
      end
      client.api_username = api_username
      client
    end

    def apply_call(group_member)
      begin
        user_details = @admin_client.user(group_member['username'])
        @mock ? sleep(0) : sleep(2)
      rescue DiscourseApi::TooManyRequests
        puts 'Sleeping for 20 seconds ....'
        @mock ? sleep(0) : sleep(20)
        user_details = @admin_client.user(group_member['username'])
      end

      if user_details['staged']
        @discourse_counters[:'Skipped Users'] += 1
      else
        user_client = @mock || connect_to_instance(user_details['username'], @options[:instance])
        # begin
        #   users_categories = user_client.categories
        #   @mock ? sleep(0) : sleep(1)
        # rescue DiscourseApi::UnauthenticatedError
        #   users_categories = nil
        #   puts "\n#{user_details['username']} : DiscourseApi::UnauthenticatedError - Not permitted to view resource.\n"
        # rescue DiscourseApi::TooManyRequests
        #   puts 'Sleeping for 20 seconds ....'
        #   @mock ? sleep(0) : sleep(20)
        #   users_categories = user_client.categories
        # end

        @discourse_counters[:'Processed Users'] += 1
        @mock ? man = nil : man = MomentumApi::Man.new(self, user_client, user_details)
        @mock ? @mock.membership_scan(self) : man.membership_scan
      end
    end

    def apply_to_users(schedule_options, skip_staged_user=true)      # move to schedule_options
      if @options[:target_groups]
        @options[:target_groups].each do |group_name|
          apply_to_group_users(group_name, skip_staged_user)
        end
      else
        apply_to_group_users('trust_level_1', skip_staged_user)
      end
    end

    def apply_to_group_users(group_name, skip_staged_user=false)
      group_members = @admin_client.group_members(group_name, limit: 10000)
      group_members.each do |group_member|
        if @options[:target_username]
          if group_member['username'] == @options[:target_username]
            apply_call(group_member)
          end
        elsif not @exclude_user_names.include?(group_member['username'])
          if @issue_users.include?(group_member['username'])
            puts "#{group_member['username']} in apply_to_group_users method"
          end
          # puts user['username']
          printf "%-15s %s \r", 'Scanning User: ', @discourse_counters[:'Processed Users']
          apply_call(group_member)
        else
        end
      end
    end



    def zero_discourse_counters
      @discourse_counters[:'Processed Users']    =   0      # @user_count
      @discourse_counters[:'Skipped Users']      =   0      # @skipped_users
      @discourse_counters[:'Messages Sent']      =   0      # @skipped_users
    end


    def scan_summary
      field_settings = "%-35s %-20s \n"

      @scan_pass_counters.each do |score|
        printf "\n\n"
        score.each do |key, value|
          printf field_settings, key.to_s, value
        end
      end
    end


    private


    # def handle_error(response)
    #   case response.status
    #   when 403
    #     raise DiscourseApi::UnauthenticatedError.new(response.env[:body], response.env)
    #   when 404, 410
    #     raise DiscourseApi::NotFoundError.new(response.env[:body], response.env)
    #   when 422
    #     raise DiscourseApi::UnprocessableEntity.new(response.env[:body], response.env)
    #   when 429
    #     raise DiscourseApi::TooManyRequests.new(response.env[:body], response.env)
    #   when 500...600
    #     raise DiscourseApi::Error.new(response.env[:body])
    #   else
    #     puts 'Error not found'
    #   end
    # end

  end
end
