module MomentumApi
  class Poll
    attr_accessor :user_scores
    # attr_reader :instance


    def initialize(master_client, post_id, poll_url='https://discourse.gomomentum.org', poll_names=%w(poll), update_type=nil)
      raise ArgumentError, 'post_id needs to be defined' if post_id.nil?

      # messages
      @emails_from_username = 'Kim_Miller'

      # parameter setting
      # @master_client        = master_client
      @post_id              = post_id
      @poll_url             = poll_url
      @poll_names           = poll_names
      @update_type          = update_type

      @user_scores          = {'User Scores': ''}

      # user score saving
      @user_fields = 'user_fields'
      @user_score_field = '5'

      zero_poll_counters

    end


    def run_scans(man)
      @man = man

      # poll settings
      @points_multiplier = 1.13

      begin
        post = @man.user_client.get_post(@post_id)
      rescue DiscourseApi::UnauthenticatedError
        return
      end
      polls = post['polls']
      users_username = @man.user_client.api_username

      polls.each do |poll|
        if @poll_names.include?(poll['name'])

          begin  # todo find and trap only specific DiscourseApi:: ... error
            poll_option_votes = @man.user_client.poll_voters(post_id: @post_id, poll_name: poll['name'], api_username: users_username)['voters']
          rescue
            # voter has not voted
            poll_option_votes = nil
          end

          # if user has voted
          if poll_option_votes
            if @update_type == 'have_voted' or @update_type == 'newly_voted' or @update_type == 'all'
              # pull user details
              # user_details = @man.user_client.user(users_username)
              # sleep 1
              user_fields = @man.user_details[@user_fields]
              existing_value = user_fields[@user_score_field].to_i

              # score voter
              current_voter_points, max_points_possible = score_voter(poll, poll_option_votes, users_username)
              user_badge_level = update_user_profile_badges(@man.user_client, current_voter_points, @man.user_details, users_username, @man.discourse.do_live_updates)

              # is this vote new?
              if existing_value == current_voter_points
                # print_scored_user(current_voter_points, existing_value, max_points_possible, poll, users_username)
                # printf "%-30s \n", 'User Score is not new.'
              else
                @user_scores[:'Voter Targets'] += 1
                # @voter_targets += 1
                update_user_profile_score(@man.user_client, current_voter_points, @man.user_details, users_username, @man.discourse.do_live_updates)
                # user_badge_level = update_user_profile_badges(client, current_voter_points, @man.user_details, users_username, @man.discourse.do_live_updates)
                print_scored_user(current_voter_points, existing_value, max_points_possible, poll, users_username, user_badge_level)
                send_voted_message(current_voter_points, max_points_possible, user_badge_level, users_username,
                                   @man.user_details, @poll_url, @man.discourse.do_live_updates)
                printf "\n"
              end

              if @update_type == 'have_voted' or @update_type == 'all'
                print_scored_user(current_voter_points, existing_value, max_points_possible, poll, users_username, user_badge_level)
                send_voted_message(current_voter_points, max_points_possible, user_badge_level, users_username,
                                   @man.user_details, @poll_url, @man.discourse.do_live_updates)
                printf "\n"
              end
              # printf "\n"
            end

            # if voter not voted
          else
            if @update_type == 'not_voted' or @update_type == 'all'
              @user_scores[:'Voter Targets'] += 1
              # @voter_targets += 1
              @user_scores[:'Users Not yet voted'] += 1
              # @user_not_voted_targets += 1
              printf "%-18s %-20s\n", users_username, 'has not voted yet'
              send_not_voted_message(users_username, @man.user_details, @poll_url, @man.discourse.do_live_updates)
              printf "\n"
            end
            next
          end
        end
      end
    end


    def send_voted_message(current_voter_points, max_points_possible, user_badge_level, users_username, voting_user, poll_url, do_live_updates)
      message_subject = "Thank You for Taking Momentum's Discourse User Poll"
      message_body = "Congratulations! Your Momentum Discourse User Score is #{current_voter_points.to_int} out of a maximum possible score of #{max_points_possible.to_int}.

  In addition to your User Score of #{current_voter_points.to_int}, you have been assigned the Momentum [**Discourse #{user_badge_level} User**](http://discourse.gomomentum.org/u/#{users_username}/badges) Badge Level. You can also visit these links to:

  - [Retake the poll and receive a new score at anytime](#{poll_url})
  - [See all Badges you have earned](https://discourse.gomomentum.org/u/#{users_username}/badges)
  - [See all the possible Momentum Badges that you can earn](https://discourse.gomomentum.org/badges)

  -- Your Momentum Moderators"

      @man.discourse.send_private_message(@emails_from_username, voting_user['username'], message_subject, message_body, do_live_updates)
    end

    def send_not_voted_message(users_username, voting_user, poll_url, do_live_updates)
      message_subject = "Momentum's Discourse User Poll is Waiting for Your Input!"
      message_body = "Your input is very important to help Momentum better understand men's Discourse experience. Please take a moment to give your input!

  Contribute to [Momentum's Discourse User Poll here](#{poll_url}). The questions are all yes / no and should take you no more than 5 minutes to complete.

  Once you take the poll you will earn a [Discourse User Badge showing your Discourse User achievement level here](https://discourse.gomomentum.org/u/#{users_username}/badges), and you can [see all possible Momentum Badges that you can earn here](https://discourse.gomomentum.org/badges).

  -- Your Momentum Moderators"

      @man.discourse.send_private_message(@emails_from_username, voting_user['username'], message_subject, message_body, do_live_updates)
    end

    def score_voter(poll, poll_option_votes, users_username)
      current_voter_votes = 0.0
      current_voter_points = 0.0
      current_question_point_value = 1.0
      max_points_possible = 0.0
      poll['options'].each do |poll_option|
        if poll_option_votes[poll_option['id']]
          option_votes = poll_option_votes[poll_option['id']]
          option_votes.each do |vote|
            if vote['username'] == users_username
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


    def update_user_profile_score(client, current_voter_points, user_details, users_username, do_live_updates=false)
      @user_scores[:'New User Scores'] += 1
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

      if do_live_updates
        update_response = client.update_user(users_username, {"#{@user_fields}": {"#{@user_score_field}": current_voter_points}})
        puts update_response[:body]['success']
        @users_updated += 1

        # check if update happened
        user_details_after_update = client.user(users_username)
        print_user_options(user_details_after_update, user_option_print, user_label='UserName',
                           pos_5=user_details_after_update[@user_fields][@user_score_field])
        sleep(1)
      end
    end

    def update_badge(client, target_badge_name, badge_id, users_username, do_live_updates=false)
      if do_live_updates
        current_badges = client.user_badges(users_username)
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
          post_response = client.grant_user_badge(username: users_username, badge_id: badge_id, reason: 'https://discourse.gomomentum.org/t/user-persona-survey/6485/20')
          # puts "User badges granted:"
          post_response.each do |badge|
            printf "%-35s %-20s \n", 'User badge granted: ', badge['name']
            # puts badge['name']
          end
        end
      end
    end

    def update_user_profile_badges(client, current_voter_points, user_details, users_username, do_live_updates=false)
      @user_scores[:'New User Badges'] += 1
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
        update_badge(client, target_badge_name, 111, users_username, do_live_updates=do_live_updates)
      when 40..375
        target_badge_name = 'Intermediate'
        # puts target_badge_name
        update_badge(client, target_badge_name, 110, users_username, do_live_updates=do_live_updates)
      when 376..1012
        target_badge_name = 'Advanced'
        # puts target_badge_name
        update_badge(client, target_badge_name, 112, users_username, do_live_updates=do_live_updates)
      when  1013..10000
        target_badge_name = 'PowerUser'
        # puts target_badge_name
        update_badge(client, target_badge_name, 113, users_username, do_live_updates=do_live_updates)
      else
        puts "Error: current_voter_points has an invalid value (#{current_voter_points})"
      end

      target_badge_name

    end


    def print_scored_user(current_voter_points, existing_value, max_points_possible, poll, users_username, user_badge_level)
      field_settings = "%-18s %-20s %-35s %-5s %-2s %-7s %-20s\n"
      printf field_settings, 'User', 'Poll', 'Last Saved Score', 'Score', '/', 'Max', 'Badge'
      printf field_settings, users_username, poll['name'], existing_value, current_voter_points, '/', max_points_possible, user_badge_level
    end

    def zero_poll_counters
      @user_scores[:'Voter Targets']        =   0
      @user_scores[:'New User Scores']      =   0
      @user_scores[:'Users Not yet voted']  =   0
      @user_scores[:'New User Badges']      =   0
    end

  end
end
