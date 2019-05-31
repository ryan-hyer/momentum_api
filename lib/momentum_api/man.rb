$LOAD_PATH.unshift File.expand_path('../../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../../discourse_api/lib/discourse_api', __FILE__)
require_relative '../momentum_api/api/notification'
require_relative '../momentum_api/api/user'
require_relative '../momentum_api/api/messages'

module MomentumApi
  class Man
    # attr_accessor :do_live_updates
    # attr_reader :instance, :api_username

    include MomentumApi::Notification
    include MomentumApi::User
    include MomentumApi::Messages

    def initialize(user_client, user_details, users_categories=nil)
      raise ArgumentError, 'user_client needs to be defined' if user_client.nil?
      raise ArgumentError, 'user_details needs to be defined' if user_details.nil? || user_details.empty?

      # messages
      @emails_from_username =   'Kim_Miller'

      # parameter setting
      @user_client          =   user_client
      @user_details         =   user_details
      @users_categories     =   users_categories

      # zero_counters

    end

    def run_scans(master_client, scan_options)
      users_groups = @user_details['groups']

      is_owner = false
      if master_client.issue_users.include?(@user_details['username'])
        puts "#{@user_details['username']} in apply_function"
      end

      # Examine Users Groups
      users_groups.each do |group|
        group_name = group['name']

        if master_client.issue_users.include?(@user_details['username'])
          puts "\n#{@user_details['username']}  with group: #{group_name}\n"
        end

        if @users_categories
          category_cases(master_client, @user_details, @users_categories, group_name, @user_client)
        else
          puts "\nSkipping Category Cases for #{@user_details['username']}.\n"
        end

        # Group Cases (make a method)
        case
        when group_name == 'Owner'
          is_owner = true
        else
          # puts 'No Group Case'
        end
      end

      # Update Trust Level
      if @trust_level_updates
        master_client.update_user_trust_level(is_owner, 0, @user_details)
      end

      # Update User Group Alias Notification
      if @user_group_alias_notify
        master_client.user_group_notify_to_default(@user_details)
      end

      # User Scoring
      if scan_options['score_user_levels'.to_sym]
        puts scan_options['score_user_levels']
        # update_type = 'newly_voted' # have_voted, not_voted, newly_voted, all
        # target_post = 28707    # 28649
        # target_polls = %w(version_two) # basic new version_two
        # poll_url = 'https://discourse.gomomentum.org/t/user-persona-survey/6485/20'
        # scan_users_score(@user_client, @user_details, target_post, target_polls, poll_url, update_type = update_type, do_live_updates = @do_live_updates)
        master_client.user_score_poll.scan_users_score(master_client, @user_client, @user_details)
      end
    end

    def category_cases(master_client, user_details, users_categories, group_name, user_client)
      starting_categories_updated = master_client.categories_updated

      users_categories.each do |category|

        if master_client.issue_users.include?(@user_details['username'])
          puts "\n#{@user_details['username']}  Category case on category: #{category['slug']}\n"
        end

        case
        when category['slug'] == group_name
          case_excludes = %w(Steve_Scott)
          if case_excludes.include?(@user_details['username'])
            # puts "#{@user_details['username']} specifically excluded from Watching Meta"
          else
            if @team_category_watching
              master_client.set_category_notification(@user_details, category, user_client, group_name, [3], 3)
            end
          end

        when (category['slug'] == 'Essential' and group_name == 'Owner')
          case_excludes = %w(Steve_Scott)
          if case_excludes.include?(@user_details['username'])
            # puts "#{@user_details['username']} specifically excluded from Essential Watching"
          else                            # 4 = Watching first post, 3 = Watching, 1 = blank or ...?
            if @essential_watching
              master_client.set_category_notification(@user_details, category, user_client, group_name, [3], 3)
            end
          end

        when (category['slug'] == 'Growth' and group_name == 'Owner')
          case_excludes = %w(Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
          if case_excludes.include?(@user_details['username'])
            # puts "#{@user_details['username']} specifically excluded from Watching Growth"
          else
            if @growth_first_post
              master_client.set_category_notification(@user_details, category, user_client, group_name, [3, 4], 4)
            end
          end

        when (category['slug'] == 'Meta' and group_name == 'Owner')
          case_excludes = %w(Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
          if case_excludes.include?(@user_details['username'])
            # puts "#{@user_details['username']} specifically excluded from Watching Meta"
          else
            if @meta_first_post
              master_client.set_category_notification(@user_details, category, user_client, group_name, [3, 4], 4)
            end
          end

        else
          # puts 'Category not a target'
        end
      end
      if master_client.categories_updated > starting_categories_updated
        master_client.users_updated += 1
      end
    end

    # def add_task(task_instance)
    #   @user_poll = task_instance
    # end

    # def connect_to_instance(api_username, instance=@instance)
    #   # @admin_client = 'KM_Admin'
    #   client = ''
    #   case instance
    #   when 'live'
    #     client = DiscourseApi::Client.new('https://discourse.gomomentum.org/')
    #     client.api_key = ENV['REMOTE_DISCOURSE_API']
    #   when 'local'
    #     client = DiscourseApi::Client.new('http://localhost:3000')
    #     client.api_key = ENV['LOCAL_DISCOURSE_API']
    #   else
    #     puts 'Host unknown'
    #   end
    #   client.api_username = api_username
    #   client
    # end

    # def apply_call(apply_fun, user)
    #   user_details = @admin_client.user(user['username'])
    #   sleep 1
    #   @user_count += 1
    #   user_client = connect_to_instance(user['username'])
    #   apply_fun.call(self, user_details, user_client)
    # end

    # def apply_to_users(apply_function, skip_staged_user=true)
    #   if @target_groups
    #     @target_groups.each do |group_name|
    #       apply_to_group_users(apply_function, group_name, skip_staged_user)
    #     end
    #   else
    #     apply_to_group_users('trust_level_1', skip_staged_user)
    #   end
    # end

    # def apply_to_group_users(apply_function, group_name, skip_staged_user=false)
    #   users = @admin_client.group_members(group_name, limit: 10000)
    #   users.each do |user|
    #     staged = staged_skip?(@admin_client, skip_staged_user, user)
    #     if staged
    #       # puts "Skipping staged user #{user['username']}"
    #     else
    #       if @target_username
    #         if user['username'] == @target_username
    #           apply_call(apply_function, user)
    #         end
    #       elsif not @exclude_user_names.include?(user['username'])
    #         if @issue_users.include?(user['username'])
    #           puts "#{user['username']} in apply_to_group_users method"
    #         end
    #         puts user['username']
    #         printf "%-15s %s \r", 'Scanning User: ', @user_count
    #         apply_call(apply_function, user)
    #       else
    #         @skipped_users += 1
    #       end
    #     end
    #   end
    # end

    # def staged_skip?(admin_client, skip_staged_user, user)
    #   staged = false
    #   if skip_staged_user
    #     if user['last_seen_at']
    #       staged = false
    #     else
    #       full_user = admin_client.user(user['username'])
    #       sleep 1
    #       staged = full_user['staged']
    #     end
    #   end
    #   staged
    # end

    # def print_user_options(user_details, user_option_print, user_label='UserName', pos_5=user_details[user_option_print[5].to_s])
    #
    #   field_settings = "%-18s %-14s %-16s %-12s %-12s %-17s %-14s\n"
    #
    #   printf field_settings, user_label,
    #          user_option_print[0], user_option_print[1], user_option_print[2],
    #          user_option_print[3], user_option_print[4], user_option_print[5]
    #
    #   printf field_settings, user_details['username'],
    #          user_details[user_option_print[0].to_s].to_s[0..9], user_details[user_option_print[1].to_s].to_s[0..9],
    #          user_details[user_option_print[2].to_s], user_details[user_option_print[3].to_s],
    #          user_details[user_option_print[4].to_s], pos_5
    # end


    # def zero_counters
    #   @user_count                       = 0
    #   @user_targets                     = 0
    #   @users_updated                    = 0
    #   @sent_messages                    = 0
    #   @skipped_users                    = 0
    #   @matching_category_notify_users   = 0
    #   @matching_categories_count        = 0
    #   @categories_updated               = 0
    #   @scan_passes                      = 0
    # end

    # def scan_summary
    #   field_settings = "%-35s %-20s \n"
    #
    #   if @matching_category_notify_users > 0
    #     printf "\n"
    #     printf field_settings, 'Categories', ''
    #     printf field_settings, 'Categories Visible to Users: ', @matching_categories_count
    #     printf field_settings, 'Users Needing Update: ', @matching_category_notify_users
    #     printf field_settings, 'Updated Categories: ', @categories_updated
    #     printf field_settings, 'Updated Users: ', @users_updated
    #   end
    #
    #   if @all_scores.empty?
    #     puts 'No scores ...'
    #   else
    #     @all_scores.each do |score|
    #       printf "\n\n"
    #       score.each do |key, value|
    #         printf field_settings, key.to_s, value
    #       end
    #     end
    #   end
    #
    #   printf "\n"
    #   # printf "\n"
    #   printf field_settings, 'Generalized targets: ', @user_targets # todo needs custom on each task
    #   printf field_settings, 'Processed Users: ', @user_count
    #   printf field_settings, 'Skipped Users: ', @skipped_users
    #   printf field_settings, 'User messages sent: ', @sent_messages
    # end
    #
    #
    # private
    #
    #
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
    #   end
    # end

  end
end
