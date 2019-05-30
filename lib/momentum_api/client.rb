$LOAD_PATH.unshift File.expand_path('../../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../../discourse_api/lib/discourse_api', __FILE__)
require_relative '../momentum_api/notification'
require_relative '../momentum_api/user'

module MomentumApi
  class Client
    attr_accessor :do_live_updates, :issue_users, :users_updated, :categories_updated
    # attr_reader :instance, :api_username

    include MomentumApi::Notification
    include MomentumApi::User

    def initialize(api_username, instance, do_live_updates=false, target_groups=[], target_username=nil)
      raise ArgumentError, 'api_username needs to be defined' if api_username.nil? || api_username.empty?

      @do_live_updates    = do_live_updates
      @target_groups      = target_groups
      @api_username       = api_username
      @instance           = instance
      @admin_client       = connect_to_instance(api_username, instance)

      @target_username    = target_username
      @exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin
                            Joe_Sabolefski Steve_Scott Howard_Bailey)
      @issue_users        = %w()
      zero_counters

    end


    def connect_to_instance(api_username, instance=@instance)
      # @admin_client = 'KM_Admin'
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

    def apply_call(apply_fun, user)
      user_details = @admin_client.user(user['username'])    # todo trap DiscourseApi::TooManyRequests
      sleep 1
      @user_count += 1
      user_client = connect_to_instance(user['username'])
      apply_fun.call(self, user_details, user_client)
    end

    def apply_to_users(apply_function, skip_staged_user=true)
      if @target_groups
        @target_groups.each do |group_name|
          apply_to_group_users(apply_function, group_name, skip_staged_user)
        end
      else
        apply_to_group_users('trust_level_1', skip_staged_user)
      end
    end

    def apply_to_group_users(apply_function, group_name, skip_staged_user=false)
      users = @admin_client.group_members(group_name, limit: 10000)
      users.each do |user|
        staged = staged_skip?(@admin_client, skip_staged_user, user)
        if staged
          # puts "Skipping staged user #{user['username']}"
        else
          if @target_username
            if user['username'] == @target_username
              apply_call(apply_function, user)
            end
          elsif not @exclude_user_names.include?(user['username'])
            if @issue_users.include?(user['username'])
              puts "#{user['username']} in apply_to_group_users method"
            end
            printf "%-15s %s \r", 'Scanning User: ', @user_count
            apply_call(apply_function, user)
          else
            @skipped_users += 1
          end
        end
      end
    end

    def staged_skip?(admin_client, skip_staged_user, user)
      staged = false
      if skip_staged_user
        if user['last_seen_at']
          staged = false
        else
          full_user = admin_client.user(user['username'])
          sleep 1
          staged = full_user['staged']
        end
      end
      staged
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


    def zero_counters
      @user_count, @user_targets, @voter_targets, @new_user_score_targets, @users_updated, @user_not_voted_targets, @new_user_badge_targets,
          @sent_messages, @skipped_users, @matching_category_notify_users, @matching_categories_count,
          @categories_updated, @scan_passes = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    end

    def scan_summary
      field_settings = "%-35s %-20s \n"

      if @matching_category_notify_users > 0
        printf "\n"
        printf field_settings, 'Categories', ''
        printf field_settings, 'Categories Visible to Users: ', @matching_categories_count
        printf field_settings, 'Users Needing Update: ', @matching_category_notify_users
        printf field_settings, 'Updated Categories: ', @categories_updated
        printf field_settings, 'Updated Users: ', @users_updated
      end

      if @voter_targets > 0
        printf "\n"
        printf field_settings, 'User Scores', ''
        printf field_settings, 'Voter Targets: ', @voter_targets
        printf field_settings, 'New User Scores: ', @new_user_score_targets
        printf field_settings, 'New User Badges: ', @new_user_badge_targets
        printf field_settings, 'Users Not yet voted:', @user_not_voted_targets
        printf field_settings, 'User messages sent: ', @sent_messages
      end


      printf "\n"
      printf "\n"
      printf field_settings, 'Generalized targets: ', @user_targets #todo needs custom on each task
      printf field_settings, 'Processed Users: ', @user_count
      printf field_settings, 'Skipped Users: ', @skipped_users
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
      end
    end

  end
end
