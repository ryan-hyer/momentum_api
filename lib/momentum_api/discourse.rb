$LOAD_PATH.unshift File.expand_path('../../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../../discourse_api/lib/discourse_api', __FILE__)
# require_relative '../momentum_api/error'
require_relative '../momentum_api/schedule'
require_relative '../momentum_api/man'

module MomentumApi
  class Discourse
    attr_reader :options, :scan_pass_counters, :admin_client, :schedule
    attr_accessor :counters

    def initialize(discourse_options, schedule_options, mock: nil)
      raise ArgumentError, 'api_username needs to be defined' if discourse_options.nil? || discourse_options.empty?

      # parameter setting
      @options              = discourse_options

      @mock                 = mock
      @admin_client         = mock || connect_to_instance(discourse_options[:api_username], discourse_options[:instance])

      # counter init
      @counters             = {'Discourse Men': ''}
      @scan_pass_counters   = []
      @scan_pass_counters   << @counters

      # create schedule Class
      @schedule             = MomentumApi::Schedule.new(self, schedule_options)

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
        puts 'TooManyRequests: Sleeping for 20 seconds ....'
        @mock ? sleep(0) : sleep(20)
        user_details = @admin_client.user(group_member['username'])
      end

      if user_details['staged']
        @counters[:'Skipped Users'] += 1
      else
        user_client = @mock || connect_to_instance(user_details['username'], @options[:instance])

        @counters[:'Processed Users'] += 1
        @mock ? @mock.scan_contexts(self) : MomentumApi::Man.new(self, user_client, user_details).scan_contexts
      end
    end

    def apply_to_users(skip_staged_user=true)      # move to schedule_options
      if @options[:target_groups] and not @options[:target_groups].empty?
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
        elsif not @options[:exclude_users].include?(group_member['username'])
          if @options[:issue_users].include?(group_member['username'])
            puts "#{group_member['username']} in apply_to_group_users method"
          end
          # puts user['username']
          printf "%-15s %s \r", 'Scanning User: ', @counters[:'Processed Users']
          apply_call(group_member)
        else
        end
      end
    end



    def zero_discourse_counters
      @counters[:'Processed Users']    =   0
      @counters[:'Skipped Users']      =   0
      @counters[:'Messages Sent']      =   0
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
