module MomentumApi
  class Poll

    attr_accessor :user_scores_counters    # todo can be deleted?
    # attr_reader :instance


    def initialize(schedule, score_user_levels)
      raise ArgumentError, 'schedule needs to be defined' if schedule.nil?
      raise ArgumentError, 'score_user_levels needs to be defined' if score_user_levels.nil? || score_user_levels.empty?


      # poll settings
      @points_multiplier      = 1.13
      @emails_from_username   = 'Kim_Miller'

      # parameter setting
      @update_type        = score_user_levels['update_type'.to_sym]
      @post_id            = score_user_levels['target_post'.to_sym]
      @poll_names         = score_user_levels['target_polls'.to_sym]
      @poll_url           = score_user_levels['poll_url'.to_sym]

      @user_scores_counters   = {'User Scores': ''}
      schedule.discourse.scan_pass_counters << @user_scores_counters

      # user score saving
      @user_fields            = 'user_fields'
      @user_score_field       = '5'

      zero_poll_counters

    end


    def run(man)
      @man = man

      begin
        post = @man.user_client.get_post(@post_id)
      rescue DiscourseApi::UnauthenticatedError
        return
      end
      polls = post['polls']
      polls.each do |poll|
        if @poll_names.include?(poll['name'])

          begin
            poll_option_votes = @man.user_client.poll_voters(post_id: @post_id, poll_name: poll['name'],
                                                             api_username: @man.user_details['username'])['voters']
          rescue DiscourseApi::UnprocessableEntity   # voter has not voted
            poll_option_votes = nil
          end
          sleep 1

          # if user has voted
          if poll_option_votes
            if @update_type == 'have_voted' or @update_type == 'newly_voted' or @update_type == 'all'
              user_fields = @man.user_details[@user_fields]
              existing_value = user_fields[@user_score_field].to_i

              # score voter
              current_voter_points, max_points_possible = score_voter(poll, poll_option_votes)
              user_badge_level = update_user_profile_badges(current_voter_points)

              # is this vote new?
              if existing_value == current_voter_points
                # print_scored_user(current_voter_points, existing_value, max_points_possible, poll, @man.user_details['username'])
                # printf "%-30s \n", 'User Score is not new.'
              else
                @user_scores_counters[:'New Vote Targets'] += 1
                # @voter_targets += 1
                update_user_profile_score(current_voter_points)
                print_scored_user(current_voter_points, existing_value, max_points_possible, poll, user_badge_level)
                send_voted_message(current_voter_points, max_points_possible, user_badge_level, @poll_url)
                printf "\n"
              end

              if @update_type == 'have_voted' or @update_type == 'all'
                print_scored_user(current_voter_points, existing_value, max_points_possible, poll, user_badge_level)
                send_voted_message(current_voter_points, max_points_possible, user_badge_level, @poll_url)
                printf "\n"
              end
              # printf "\n"
            end

            # if voter not voted
          else
            if @update_type == 'not_voted' or @update_type == 'all'
              @user_scores_counters[:'Not Voted Targets'] += 1
              printf "%-18s %-20s\n", @man.user_details['username'], 'has not voted yet'
              send_not_voted_message(@poll_url)
              printf "\n"
            end
            # next
          end
        end
      end
    end


    def send_voted_message(current_voter_points, max_points_possible, user_badge_level, poll_url)
      message_subject = "Thank You for Taking Momentum's Discourse User Poll"
      message_body = "Congratulations! Your Momentum Discourse User Score is #{current_voter_points.to_int} out of a maximum possible score of #{max_points_possible.to_int}.

  In addition to your User Score of #{current_voter_points.to_int}, you have been assigned the Momentum [**Discourse #{user_badge_level} User**](http://discourse.gomomentum.org/u/#{@man.user_details['username']}/badges) Badge Level. You can also visit these links to:

  - [Retake the poll and receive a new score at anytime](#{poll_url})
  - [See all Badges you have earned](https://discourse.gomomentum.org/u/#{@man.user_details['username']}/badges)
  - [See all the possible Momentum Badges that you can earn](https://discourse.gomomentum.org/badges)

  -- Your Momentum Moderators"

      @man.discourse.send_private_message(@emails_from_username, @man.user_details['username'],
                                          message_subject, message_body, @man.discourse.do_live_updates)
    end

    def send_not_voted_message(poll_url)
      message_subject = "Momentum's Discourse User Poll is Waiting for Your Input!"
      message_body = "Your input is very important to help Momentum better understand men's Discourse experience. Please take a moment to give your input!

  Contribute to [Momentum's Discourse User Poll here](#{poll_url}). The questions are all yes / no and should take you no more than 5 minutes to complete.

  Once you take the poll you will earn a [Discourse User Badge showing your Discourse User achievement level here](https://discourse.gomomentum.org/u/#{@man.user_details['username']}/badges), and you can [see all possible Momentum Badges that you can earn here](https://discourse.gomomentum.org/badges).

  -- Your Momentum Moderators"

      @man.discourse.send_private_message(@emails_from_username, @man.user_details['username'],
                                          message_subject, message_body, @man.discourse.do_live_updates)
    end

    def score_voter(poll, poll_option_votes)
      current_voter_votes = 0.0
      current_voter_points = 0.0
      current_question_point_value = 1.0
      max_points_possible = 0.0
      poll['options'].each do |poll_option|
        if poll_option_votes[poll_option['id']]
          option_votes = poll_option_votes[poll_option['id']]
          option_votes.each do |vote|
            if vote['username'] == @man.user_details['username']
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
      @user_scores_counters[:'New User Scores'] += 1
      # @new_user_score_targets += 1
      # puts 'User Score to be updated'
      user_option_print = %w(
      last_seen_at
      last_posted_at
      post_count
      time_read
      recent_time_read
      user_field_score
  )
      print_user_options(@man.user_details, user_option_print, user_label='UserName', pos_5=@man.user_details[@user_fields][@user_score_field])

      if @man.discourse.do_live_updates
        update_response = @man.user_client.update_user(@man.user_details['username'], {"#{@user_fields}": {"#{@user_score_field}": current_voter_points}})
        puts update_response[:body]['success']
        @user_scores_counters[:'Updated User Scores'] += 1

        # check if update happened
        user_details_after_update = @man.user_client.user(@man.user_details['username'])
        print_user_options(user_details_after_update, user_option_print, user_label='UserName',
                           pos_5=user_details_after_update[@user_fields][@user_score_field])
        sleep(1)
      end
    end

    def update_badge(target_badge_name, badge_id)
      if @man.discourse.do_live_updates
        current_badges = @man.user_client.user_badges(@man.user_details['username'])
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
          post_response = @man.user_client.grant_user_badge(username: @man.user_details['username'], badge_id: badge_id, reason: 'https://discourse.gomomentum.org/t/user-persona-survey/6485/20')
          # puts "User badges granted:"
          post_response.each do |badge|
            printf "%-35s %-20s \n", 'User badge granted: ', badge['name']
            # puts badge['name']
          end
        end
      end
    end

    def update_user_profile_badges(current_voter_points)
      @user_scores_counters[:'New User Badges'] += 1
      # @new_user_badge_targets += 1
      target_badge_name = nil
      # puts 'User Badges to be updated'
      # print_user_options(@man.user_details, user_option_print)

      # calculate badges
      case current_voter_points
      when 0
        puts "You ran out of gas."
      when 1..7
        puts "Keep trying!"
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
        puts "Error: current_voter_points has an invalid value (#{current_voter_points})"
      end

      target_badge_name

    end


    def print_scored_user(current_voter_points, existing_value, max_points_possible, poll, user_badge_level)
      field_settings = "%-18s %-20s %-35s %-5s %-2s %-7s %-20s\n"
      printf field_settings, 'User', 'Poll', 'Last Saved Score', 'Score', '/', 'Max', 'Badge'
      printf field_settings, @man.user_details['username'], poll['name'], existing_value, current_voter_points, '/', max_points_possible, user_badge_level
    end

    def zero_poll_counters
      @user_scores_counters[:'New Vote Targets']         =   0
      @user_scores_counters[:'New User Scores']          =   0
      @user_scores_counters[:'Updated User Scores']      =   0
      @user_scores_counters[:'New User Badges']          =   0
      @user_scores_counters[:'Not Voted Targets']        =   0
    end

  end
end
