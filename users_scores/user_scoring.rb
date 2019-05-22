require '../utility/momentum_api'
require '../users_scores/user_scores_utility'

def scan_user_scores(do_live_updates=false, update_type='have_voted')

  @do_live_updates = do_live_updates
  @instance = 'live' # 'live' or 'local'

  # which users
  @target_groups = %w(Mods)

  # messages
  @from_username = 'Kim_Miller'  # KM_Admin Kim_Miller

  # poll parameters
  @update_type = update_type  # have_voted, not_voted, both, newly_voted
  @target_post = 28707     # 28649
  @target_polls = %w(version_two)  # basic new
  @points_multiplier = 1.13
  @users_score = 0
  @max_points_possible = 0
  @poll_url = 'https://discourse.gomomentum.org/t/user-persona-survey/6485/20'

  # user score saving
  @user_preferences = 'user_fields'
  @user_score_field = '5'
  @user_option_print = %w(
      last_seen_at
      last_posted_at
      post_count
      time_read
      recent_time_read
      5
  )

  # testing variables
  # @target_username = 'KM_Admin'  # David_Ashby, Ryan_Hyer,Stefan_Schmitz KM_Admin Kim_Miller
  @issue_users = %w() # debug issue user_names

  @exclude_user_names = %w()  # js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin
  @field_settings = "%-18s %-20s %-10s %-10s %-5s %-2s %-7s\n"

  @user_count, @user_targets, @new_user_score_targets, @users_updated, @user_not_voted_targets, @new_user_badge_targets,
      @sent_messages = 0, 0, 0, 0, 0, 0, 0

  def send_voted_message(current_voter_points, max_points_possible, user_badge_level, users_username, voting_user)
    message_subject = "Thank You for Taking Momentum's Discourse User Poll"
    message_body = "Congratulations! Your Momentum Discourse User Score is #{current_voter_points.to_int} out of a maximum possible score of #{max_points_possible.to_int}.

  In addition to your User Score of #{current_voter_points.to_int}, you have been assigned the Momentum [**Discourse #{user_badge_level} User**](http://discourse.gomomentum.org/u/#{users_username}/badges) Badge Level. You can also visit these links to:

  - [Retake the poll and receive a new score at anytime](#{@poll_url})
  - [See all Badges you have earned](https://discourse.gomomentum.org/u/#{users_username}/badges)
  - [See all the possible Momentum Badges that you can earn](https://discourse.gomomentum.org/badges)

  -- Your Momentum Moderators"

    send_private_message(@from_username, voting_user['username'], message_subject, message_body)
  end

  def print_scored_user(current_voter_points, existing_value, max_points_possible, poll, users_username)
    field_settings = "%-18s %-20s %-35s %-5s %-2s %-7s\n"
    printf field_settings, 'User', 'Poll', 'Last Saved Score', 'Score', '/', 'Max'
    printf field_settings, users_username, poll['name'], existing_value, current_voter_points, '/', max_points_possible
  end

  def apply_function(client, voting_user)
    post = client.get_post(@target_post)
    polls = post['polls']
    users_username = client.api_username
    @user_count += 1

    polls.each do |poll|
      if @target_polls.include?(poll['name'])

        begin
          poll_option_votes = client.voters(post_id: @target_post, poll_name: poll['name'], api_username: users_username)['voters']
          # user has voted
          if @update_type == 'have_voted' or @update_type == 'newly_voted' or @update_type == 'both'
            # score voter
            current_voter_points, max_points_possible = score_voter(poll, poll_option_votes, users_username)

            # is this vote new?
            user_details = client.user(users_username)
            user_fields = user_details[@user_preferences]
            existing_value = user_fields[@user_score_field].to_i

            if existing_value == current_voter_points
              # print_scored_user(current_voter_points, existing_value, max_points_possible, poll, users_username)
              # printf "%-30s \n", 'User Score is not new.'
            else
              @user_targets += 1
              update_user_profile_score(client, current_voter_points, user_details, users_username)
              user_badge_level = update_user_profile_badges(client, current_voter_points, user_details, users_username)
              print_scored_user(current_voter_points, existing_value, max_points_possible, poll, users_username)
              send_voted_message(current_voter_points, max_points_possible, user_badge_level, users_username, voting_user)
              printf "\n"
            end

            if @update_type == 'have_voted'
              print_scored_user(current_voter_points, existing_value, max_points_possible, poll, users_username)
              send_voted_message(current_voter_points, max_points_possible, user_badge_level, users_username, voting_user)
              printf "\n"
            end
            # printf "\n"
          end

        rescue
          if @update_type == 'not_voted' or @update_type == 'both'
            # voter has not voted
            @user_targets += 1
            @user_not_voted_targets += 1
            printf @field_settings, users_username, 'has not voted yet', '', '', '', '', '', ''
            # not yet voted message details
            message_subject = "Momentum's Discourse User Poll is Waiting for Your Input!"
            message_body = "Your input is very important to help Momentum better understand men's Discourse experience. Please take a moment to give your input!

  Contribute to [Momentum's Discourse User Poll here](#{@poll_url}). The questions are all yes / no and should take you no more than 5 minutes to complete.

  Once you take the poll you will earn a [Discourse User Badge showing your Discourse User achievement level here](https://discourse.gomomentum.org/u/#{users_username}/badges), and you can [see all possible Momentum Badges that you can earn here](https://discourse.gomomentum.org/badges).

  -- Your Momentum Moderators"

            send_private_message(@from_username, voting_user['username'], message_subject, message_body)
            printf "\n"
          end
          next
        end
      end
    end
  end


  if @target_groups
    @target_groups.each do |group_plug|
      apply_to_group_users(group_plug, needs_user_client=true, skip_staged_user=true)
    end
  else
    apply_to_all_users
  end

end

if __FILE__ == $0

  scan_user_scores(do_live_updates = false)

  printf "%-30s %-20s \n", 'Qualifying targets: ', @user_targets
  printf "%-30s %-20s \n", 'New User Scores: ', @new_user_score_targets
  printf "%-30s %-20s \n", 'Users Not yet voted:', @user_not_voted_targets
  printf "%-30s %-20s \n", 'User messages sent: ', @sent_messages
  printf "%-30s %-20s \n", 'Total Users: ', @user_count

end
