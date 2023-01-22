# $LOAD_PATH.unshift File.expand_path('../../../../discourse_api/lib', __FILE__)          # uncomment for local 'discourse_api'
# require File.expand_path('../../../../discourse_api/lib/discourse_api', __FILE__)       # uncomment for local 'discourse_api'
# require 'discourse_api'                                                                   # for gem 'discourse_api'
require '/var/lib/gems/2.7.0/gems/discourse_api-0.40.0/lib/discourse_api'

module MomentumApi
  class Discourse
    attr_reader :options, :scan_pass_counters, :admin_client, :schedule
    attr_accessor :counters

    def initialize(discourse_options, schedule_options: nil, mock: nil)
      raise ArgumentError, 'api_username needs to be defined' if discourse_options.nil? || discourse_options.empty?

      # parameter setting
      @options              = discourse_options

      @mock                 = mock
      @admin_client         = mock || connect_to_instance(discourse_options[:api_username], discourse_options[:instance])

      # counter init
      @counters             = {'Discourse Men': ''}
      @scan_pass_counters   = []
      @scan_pass_counters   << @counters

      # load schedule options
      @schedule_options     = schedule_options
      zero_discourse_counters

    end

    def connect_to_instance(api_username, instance=@options[:instance])
      add_momentum_api_endpoints

      case instance
      when 'https://discourse.gomomentum.org'
        client = DiscourseApi::Client.new('https://discourse.gomomentum.org')
        client.api_key = ENV['REMOTE_DISCOURSE_API']
      when 'https://staging.gomomentum.org'
        client = DiscourseApi::Client.new('https://staging.gomomentum.org')
        client.api_key = ENV['STAGING_DISCOURSE_API']  # STAGING_DISCOURSE_API
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

    def apply_to_users(skip_staged_user=true)      # move to schedule_options
      schedule_options = @schedule_options || YAML.load_file(File.expand_path('../../../_run_config.yml', __FILE__))
      @schedule        = MomentumApi::Schedule.new(self, schedule_options)

      if @options[:target_groups] and not @options[:target_groups].empty?
        @options[:target_groups].each(&method(:group_applied))
      else
        group_applied('trust_level_1')
      end
    end

    def scan_summary

      field_settings = "%-35s %-20s"

      @scan_pass_counters.each do |score|
        # @options[:logger].info "\n"
        score.each do |key, value|
          summary_detail = sprintf field_settings, key.to_s, value
          @options[:logger].info summary_detail
        end
      end
    end


    private
    
    def apply_call(group_member)
      if @options[:debug_mode]
        puts group_member['username']
      end
      begin
        user_details = @admin_client.user(group_member['username'])
        @mock ? sleep(0) : sleep(2)
      rescue DiscourseApi::TooManyRequests
        @options[:logger].warn 'TooManyRequests: Sleeping for 20 seconds ....'
        @mock ? sleep(0) : sleep(20)
        user_details = @admin_client.user(group_member['username'])
      rescue DiscourseApi::NotFoundError => exception
        @users_categories = nil
        @discourse.options[:logger].warn "#{group_member['username']} : DiscourseApi::NotFoundError -- #{exception.class}, #{exception.message}:"
        @mock ? sleep(0) : sleep(10 * 60)
        user_details = @admin_client.user(group_member['username'])
      end

      user_active = true
      if user_details['staged']
        # todo /admin/users/478.json?  method users
        @mock ? sleep(0) : sleep(1)
        # if false       # future use ?
        #   user_active = false
        # end
      end

      if user_details['staged'] and user_details['staged'] and not @options[:include_staged_users] or not user_active
        @counters[:'Skipped Users'] += 1
      else
        user_client = @mock || connect_to_instance(user_details['username'], @options[:instance])
        @mock ? @mock.run(self) : MomentumApi::Man.new(self, user_client, user_details).run
        @counters[:'Processed Users'] += 1
      end
    end

    def apply_to_group_users(group_name)      # 10000 not allowed in 2.4
      group_members = @admin_client.group_members(group_name, limit: 1000) # todo add errors rescues
      group_members.each do |group_member|
        if @options[:issue_users].include?(group_member['username'])
          puts "#{group_member['username']} in apply_to_group_users method"
        end

        if @options[:target_username]
          if group_member['username'] == @options[:target_username]
            apply_call(group_member)
          end
        elsif not @options[:exclude_users].include?(group_member['username'])
          printf "%-15s %s \r", 'Scanning User: ', @counters[:'Processed Users']
          apply_call(group_member)
        else
        end
      end
    end

    def add_momentum_api_endpoints
     DiscourseApi::Client.class_eval do

       def get_subscriptions(user_id)
         begin
           response = get("/s/user/subscriptions.json")
           subscription = response[:body]
           # puts subscription
         rescue DiscourseApi::UnauthenticatedError
           subscription = []
           # discourse.options[:logger].warn "User ID: #{user_id} : membership_subscriptions: DiscourseApi::UnauthenticatedError."
         end
         subscription
       end

     end
   end

    def group_applied(group_name)
      apply_to_group_users(group_name)
    end

    def zero_discourse_counters
      @counters[:'Processed Users']    =   0
      @counters[:'Skipped Users']      =   0
      @counters[:'Messages Sent']      =   0
    end
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
