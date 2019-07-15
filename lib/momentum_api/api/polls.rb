module MomentumApi
  class Poll

    attr_accessor :counters

    def initialize(schedule, poll_options, mock: nil)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'poll_options needs to be defined' if poll_options.nil? || poll_options.empty?

      # parameter setting
      @schedule               =   schedule
      @options                =   poll_options
      @mock                   =   mock

      @message_client         =   mock || MomentumApi::Messages.new(self, poll_options[:messages_from])

      # counter init
      @counters               =   {'User Scores': ''}
      schedule.discourse.scan_pass_counters << @counters

      # poll settings                           todo move params into poll options hash
      @points_multiplier      =   1.13
      @user_fields            =   'user_fields'
      @user_score_field       =   '5'
      # @emails_from_username   =   'Kim_Miller'

      zero_poll_counters

    end


    def run(man)
      # puts 'issue user here'
      if @options[:excludes].include?(man.user_details['username'])
        # puts "#{man.user_details['username']} is Excluded from this Poll."

      else
        @man = man

        begin
          post = get_poll_post
        rescue DiscourseApi::UnauthenticatedError
          @schedule.discourse.options[:logger].warn "#{man.user_details['username']} does not have access to Poll Post."
          return 'UnauthenticatedError'
        end
        @mock ? sleep(0) : sleep(1)

        if @options[:target_polls].nil? or @options[:target_polls].empty?
          @options[:target_polls] = %w(poll)
        end

        post['polls'].each do |poll|
          if @options[:target_polls].include?(poll['name'])

            poll_option_votes = has_man_voted?(poll)

            if poll_option_votes
              # user has voted
              if @options[:update_type] == 'have_voted' or @options[:update_type] == 'newly_voted' or @options[:update_type] == 'all'
                user_fields = @man.user_details[@user_fields]
                existing_value = user_fields[@user_score_field].to_i

                # score voter
                current_voter_points, max_points_possible = score_voter(poll, poll_option_votes)
                user_badge_level = update_user_profile_badges(current_voter_points)

                if existing_value == current_voter_points
                  # existing vote
                  if @options[:update_type] == 'have_voted' or @options[:update_type] == 'all'
                    print_scored_user(current_voter_points, existing_value, max_points_possible, poll, user_badge_level)
                    send_voted_message(current_voter_points, max_points_possible, user_badge_level)
                    # printf "\n"
                  end
                else
                  # new vote
                  @counters[:'New Vote Targets'] += 1
                  update_user_profile_score(current_voter_points)
                  print_scored_user(current_voter_points, existing_value, max_points_possible, poll, user_badge_level)
                  send_voted_message(current_voter_points, max_points_possible, user_badge_level)
                end
              end

            else
              # user has not voted
              if @options[:update_type] == 'not_voted' or @options[:update_type] == 'all'
                @counters[:'Not Voted Targets'] += 1
                not_voted = sprintf "%-18s %-20s", @man.user_details['username'], 'has not voted yet'
                man.discourse.options[:logger].info not_voted
                send_not_voted_message
              end
              # next
            end
          end
        end
      end
    end


    def send_voted_message(current_voter_points, max_points_possible, user_badge_level)
      message_subject = "Thank You for Taking Momentum's Discourse User Quiz"
      message_body = eval(message_body('voted_message.txt'))
      @message_client.send_private_message(@man, message_body, message_subject)
    end

    def send_not_voted_message
      # message_subject = "What's Your Score? Please Take Your User Quiz and Find Out!"
      message_subject = "It's Not Too Late To Be Counted"
      # message_body = eval(message_body('not_voted_message.txt'))
      message_body = eval(message_body('not_voted_message_3.txt'))
      @message_client.send_private_message(@man, message_body, message_subject)
      sleep 2   # mass emails can easily trigger TooManyRequests
    end

    def score_voter(poll, poll_option_votes)
      current_voter_votes = 0.0
      current_voter_points = 0.0
      current_question_point_value = 1.0
      max_points_possible = 0.0
      voter = @man.user_details['username']
      poll['options'].each do |poll_option|
        if poll_option_votes[poll_option['id']]
          option_votes = poll_option_votes[poll_option['id']]
          option_votes.each do |vote|
            if vote['username'] == voter
              # puts vote['username'], poll_option['html']
              current_voter_votes += 1
              current_voter_points = current_voter_points + current_question_point_value
            end
          end
        end
        max_points_possible = max_points_possible + current_question_point_value
        current_question_point_value = current_question_point_value * @points_multiplier
      end

      return current_voter_points.to_int, max_points_possible.to_int
    end


    def update_user_profile_score(current_voter_points)
      @counters[:'New User Scores'] += 1
      # puts 'User Score to be updated'
      # user_option_print = %w(last_seen_at last_posted_at post_count time_read recent_time_read user_field_score)
      @man.print_user_options(@man.user_details, user_label: 'UserName',
                              nested_user_field: %W(#{@user_fields} #{@user_score_field}))
                              # user_field: @man.user_details[@user_fields][@user_score_field])

      if @schedule.discourse.options[:do_live_updates]
        update_response = @schedule.discourse.admin_client.update_user(
            @man.user_details['username'], {"#{@user_fields}": {"#{@user_score_field}": current_voter_points}})
        @schedule.discourse.options[:logger].warn "Success: #{update_response[:body]['success']}"
        @counters[:'Updated User Scores'] += 1

        # check if update happened
        user_details_after_update = @schedule.discourse.admin_client.user(@man.user_details['username'])
        @man.print_user_options(user_details_after_update, user_label: 'UserName',
                                nested_user_field: %W(#{@user_fields} #{@user_score_field}))
                                # user_field: user_details_after_update[@user_fields][@user_score_field])
        @mock ? sleep(0) : sleep(1)
      end
    end

    def update_badge(target_badge_name, badge_id)
      if @schedule.discourse.options[:do_live_updates]
        current_badges = @schedule.discourse.admin_client.user_badges(@man.user_details['username'])
        has_target_badge = false
        current_badges.each do |current_badge|
          if current_badge['name'] == target_badge_name
            has_target_badge = true
          end
        end
        if has_target_badge
          # puts 'User already has badge'
        else
          # puts 'about to post'
          @counters[:'New User Badges'] += 1
          post_response = @schedule.discourse.admin_client.grant_user_badge(
              username: @man.user_details['username'], badge_id: badge_id, reason: @options[:poll_url])
          # puts "User badges granted:"
          post_response['badges'].each do |badge|
            # puts @man.user_details['username']
            granted_badge = sprintf "%-18s %-35s %-20s", @man.user_details['username'],
                                    ' granted User Badge: ', badge['name']
            @schedule.discourse.options[:logger].info granted_badge
          end
        end
      end
    end

    def update_user_profile_badges(current_voter_points)
      # @counters[:'New User Badges'] += 1
      target_badge_name = nil

      # calculate badges
      case current_voter_points
      when 0
        # puts "You ran out of gas."
      when 1..7
        # puts "Keep trying!"
      when 8..39
        target_badge_name = 'Beginner'
        # puts target_badge_name
        update_badge(target_badge_name, 111)
      when 40..375
        target_badge_name = 'Intermediate'
        # puts target_badge_name
        update_badge(target_badge_name, 110)
      when 376..1012
        target_badge_name = 'Advanced'
        # puts target_badge_name
        update_badge(target_badge_name, 112)
      when  1013..10000
        target_badge_name = 'PowerUser'
        # puts target_badge_name
        update_badge(target_badge_name, 113)
      else
        @schedule.discourse.options[:logger].warn "Error: current_voter_points has an invalid value (#{current_voter_points})"
      end

      target_badge_name

    end


    def print_scored_user(current_voter_points, existing_value, max_points_possible, poll, user_badge_level)
      field_settings = "%-18s %-20s %-35s %-5s %-2s %-7s %-20s"
      # field_settings = "%-18s %-20s %-35s %-5s %-2s %-7s %-20s\n"
      heading = sprintf field_settings, 'User', 'Poll', 'Last Saved Score', 'Score', '/', 'Max', 'Badge'
      body = sprintf field_settings, @man.user_details['username'], poll['name'], existing_value,
                     current_voter_points, '/', max_points_possible, user_badge_level
      @schedule.discourse.options[:logger].info heading
      @schedule.discourse.options[:logger].info body
    end

    def zero_poll_counters
      @counters[:'New Vote Targets']         =   0
      @counters[:'New User Scores']          =   0
      @counters[:'Updated User Scores']      =   0
      @counters[:'New User Badges']          =   0
      @counters[:'Not Voted Targets']        =   0
      @counters[:'Messages Sent']            =   0
    end

    def message_path
      File.expand_path("../../../../polls/user_score/messages", __FILE__)
    end

    def message_body(text_file)
      File.read(message_path + '/' + text_file)
    end

    private

    def get_poll_post
      post = nil
      begin
        post = @man.user_client.get_post(@options[:target_post])

      rescue DiscourseApi::TooManyRequests
        @schedule.discourse.options[:logger].warn 'TooManyRequests: Sleeping for 30 seconds ....'
        @mock ? sleep(0) : sleep(30)
        post = get_poll_post
      rescue DiscourseApi::Error
        @schedule.discourse.options[:logger].warn 'Basic DiscourseApi::Error: Sleeping for 1 minute ....'
        @mock ? sleep(0) : sleep(60)
        post = get_poll_post
      end
      @mock ? sleep(0) : sleep(1)
      post
    end

    def has_man_voted?(poll)
      begin
        poll_option_votes = @man.user_client.poll_voters(post_id: @options[:target_post], poll_name: poll['name'],
                                                         api_username: @man.user_details['username'])['voters']
      rescue DiscourseApi::UnprocessableEntity # voter has not voted
        poll_option_votes = nil
      rescue DiscourseApi::TooManyRequests
        @schedule.discourse.options[:logger].warn 'TooManyRequests: Sleeping for 30 seconds ....'
        @mock ? sleep(0) : sleep(30)
        poll_option_votes = has_man_voted?(poll)
      rescue DiscourseApi::Error
        @schedule.discourse.options[:logger].warn 'Basic DiscourseApi::Error: Sleeping for 1 minute ....'
        @mock ? sleep(0) : sleep(60)
        poll_option_votes = has_man_voted?(poll)
      end
      @mock ? sleep(0) : sleep(1)
      poll_option_votes
    end

  end
end
