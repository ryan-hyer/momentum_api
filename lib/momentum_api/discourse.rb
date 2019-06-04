$LOAD_PATH.unshift File.expand_path('../../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../../discourse_api/lib/discourse_api', __FILE__)
require_relative '../momentum_api/man'
require_relative '../momentum_api/api/messages'

module MomentumApi
  class Discourse
    attr_accessor :do_live_updates, :issue_users, :user_targets, :users_updated, :categories_updated, :user_score_poll, :all_scan_totals,
                  :scan_options, :matching_categories_count, :categories_updated, :matching_category_notify_users, :admin_client
    # attr_reader :instance, :api_username

    include MomentumApi::Messages

    def initialize(api_username, instance, do_live_updates=false, target_groups=[], target_username=nil, mock: nil)
      raise ArgumentError, 'api_username needs to be defined' if api_username.nil? || api_username.empty?

      # messages
      @emails_from_username = 'Kim_Miller'

      # parameter setting
      @target_username    = target_username
      @target_groups      = target_groups
      @do_live_updates    = do_live_updates
      @instance           = instance
      @api_username       = api_username
      @mock               = mock
      @admin_client       = mock || connect_to_instance(api_username, instance)

      @all_scan_totals    = []

      # testing variables
      @exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin)
      @issue_users        = %w()

      # zero out counters
      zero_counters

    end

    def connect_to_instance(api_username, instance=@instance)
      client = ''
      case instance
      when 'live'
        client = DiscourseApi::Client.new('https://discourse.gomomentum.org/')
        client.api_key = ENV['REMOTE_DISCOURSE_API']
      when 'local'
        client = DiscourseApi::Client.new('http://localhost:3000')
        client.api_key = ENV['LOCAL_DISCOURSE_API']
      else
        puts 'Host unknown'
      end
      client.api_username = api_username
      client
    end

    def apply_call(user_details)
      user_client = @mock || connect_to_instance(user_details['username'], @instance)
      begin
        users_categories = user_client.categories
        sleep 1
      rescue DiscourseApi::UnauthenticatedError
        users_categories = nil
        puts "\n#{user_details['username']} : DiscourseApi::UnauthenticatedError - Not permitted to view resource.\n"
      rescue DiscourseApi::TooManyRequests
        puts 'Sleeping for 20 seconds ....'
        sleep 20
        users_categories = user_client.categories
      end

      @user_count += 1
      man = MomentumApi::Man.new(user_client, user_details, users_categories=users_categories)
      @mock ? @mock.run_scans(self) : man.run_scans(self)
    end

    def apply_to_users(scan_options, skip_staged_user=true)
      @scan_options = scan_options

      if @scan_options['team_category_watching'.to_sym]   # todo convert Notification to a Class
        # @all_scores << @user_score_poll.user_scores       # todo setup hash totals
      end

      if @scan_options['score_user_levels'.to_sym]
        update_type       = @scan_options['score_user_levels'.to_sym]['update_type'.to_sym]
        target_post       = @scan_options['score_user_levels'.to_sym]['target_post'.to_sym]
        target_polls      = @scan_options['score_user_levels'.to_sym]['target_polls'.to_sym]
        poll_url          = @scan_options['score_user_levels'.to_sym]['poll_url'.to_sym]

        @user_score_poll   = MomentumApi::Poll.new(target_post, update_type, poll_url=poll_url, poll_names=target_polls)
        @all_scan_totals << @user_score_poll.user_scores
      end

      if @target_groups
        @target_groups.each do |group_name|
          apply_to_group_users(group_name, skip_staged_user)
        end
      else
        apply_to_group_users('trust_level_1', skip_staged_user)
      end
    end

    def apply_to_group_users(group_name, skip_staged_user=false)
      group_members = @admin_client.group_members(group_name, limit: 10000)
      group_members.each do |group_member|
        begin
          user_details = @admin_client.user(group_member['username'])
          sleep 2
        rescue DiscourseApi::TooManyRequests
          puts 'Sleeping for 20 seconds ....'
          sleep 20
          user_details = @admin_client.user(group_member['username'])
        end
        staged = user_details['staged']
        if staged
          # puts "Skipping staged user #{user['username']}"
        else
          if @target_username
            if group_member['username'] == @target_username
              apply_call(user_details)
            end
          elsif not @exclude_user_names.include?(group_member['username'])
            if @issue_users.include?(group_member['username'])
              puts "#{group_member['username']} in apply_to_group_users method"
            end
            # puts user['username']
            printf "%-15s %s \r", 'Scanning User: ', @user_count
            apply_call(user_details)
          else
            @skipped_users += 1
          end
        end
      end
    end

    
    def zero_counters                             # todo move to hash
      @user_count                       = 0
      @user_targets                     = 0
      @users_updated                    = 0
      @sent_messages                    = 0
      @skipped_users                    = 0
      @matching_category_notify_users   = 0
      @matching_categories_count        = 0
      @categories_updated               = 0
      @scan_passes                      = 0
    end

    def scan_summary
      field_settings = "%-35s %-20s \n"

      if @matching_category_notify_users > 0
        printf "\n"
        printf field_settings, 'Category Notification Totals', ''
        printf field_settings, 'Categories Visible to Users: ', @matching_categories_count
        printf field_settings, 'Users Needing Update: ', @matching_category_notify_users
        printf field_settings, 'Updated Categories: ', @categories_updated
        printf field_settings, 'Updated Users: ', @users_updated
      end

      if @all_scan_totals.empty?
        puts 'No Scan totals ...'
      else
        @all_scan_totals.each do |score|
          printf "\n\n"
          score.each do |key, value|
            printf field_settings, key.to_s, value
          end
        end
      end

      printf "\n"
      # printf "\n"
      printf field_settings, 'Generalized targets: ', @user_targets # todo needs custom on each task
      printf field_settings, 'Processed Users: ', @user_count
      printf field_settings, 'Skipped Users: ', @skipped_users
      printf field_settings, 'User messages sent: ', @sent_messages
    end


    private


    def handle_error(response)
      case response.status
      when 403
        raise DiscourseApi::UnauthenticatedError.new(response.env[:body], response.env)
      when 404, 410
        raise DiscourseApi::NotFoundError.new(response.env[:body], response.env)
      when 422
        raise DiscourseApi::UnprocessableEntity.new(response.env[:body], response.env)
      when 429
        raise DiscourseApi::TooManyRequests.new(response.env[:body], response.env)
      when 500...600
        raise DiscourseApi::Error.new(response.env[:body])
      else
        puts 'Error not found'
      end
    end

  end
end
