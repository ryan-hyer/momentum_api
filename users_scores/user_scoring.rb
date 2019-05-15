require '../utility/momentum_api'
require '../users_scores/user_scores_utility'

@do_live_updates = true
@instance = 'live' # 'live' or 'local'

# testing variables
@target_username = 'KM_Admin'  # David_Ashby, Ryan_Hyer,Stefan_Schmitz KM_Admin Kim_Miller
@issue_users = %w() # debug issue user_names

# poll parameters
@target_post = 28707     # 28649
@target_polls = %w(version_two)  # basic new
@update_type = 'have_voted'  # have_voted, not_voted, both
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
# messages
@sent_messages = 0

@exclude_user_names = %w()  # js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin
@target_groups = %w(Mods)
@field_settings = "%-18s %-20s %-10s %-10s %-5s %-2s %-7s\n"

@user_count, @user_targets, @new_user_score_targets, @users_updated, @user_not_voted_targets, @new_user_badge_targets = 0, 0, 0, 0, 0, 0

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
        if @update_type == 'have_voted' or @update_type == 'both'
          # score voter
          current_voter_points, max_points_possible = score_voter(poll, poll_option_votes, users_username)

          # is this vote new?
          user_details = client.user(users_username)
          user_fields = user_details[@user_preferences]
          existing_value = user_fields[@user_score_field]
          printf "Existing value: %-20s \n", existing_value
          printf "current_voter_points: %-20s \n",  current_voter_points
          if existing_value == current_voter_points
            print_user_options(user_details)
            puts 'User Score is not new'
          else
            update_user_profile_score(client, current_voter_points, user_details, users_username)

            user_badge_level = update_user_profile_badges(client, current_voter_points, user_details, users_username)

            # send voter message
            from_username = 'Kim_Miller'  # KM_Admin
            message_subject = "Thank You for Taking Momentum's Discourse User Poll"
            message_body = "Congratulations! Your Momentum Discourse User Score is #{current_voter_points.to_int} out of a maximum possible score of #{max_points_possible.to_int}.

In addition to your Discourse User Score of #{current_voter_points.to_int}, you have been assigned the Momentum Discourse #{user_badge_level} User Badge Level.

You can [retake the poll and receive a new score at anytime here](#{@poll_url}).

You can [see all the Discourse Badges you have earned here](https://discourse.gomomentum.org/u/#{users_username}/badges) and [all possible Momentum Badges that you can earn here](https://discourse.gomomentum.org/badges).

-- Your Momentum Moderators"

            send_private_message(from_username, voting_user['username'], message_subject, message_body)
          end
        end

      rescue
        if @update_type == 'not_voted' or @update_type == 'both'
          # voter has not voted
          @user_not_voted_targets += 1
          printf @field_settings, users_username, 'has not voted yet', '', '', '', '', '', ''
          # not yet voted message details
          from_username = 'KM_Admin'  # KM_Admin Kim_Miller
          message_subject = "Momentum's Discourse User Poll is Waiting for Your Input!"
          message_body = "Please contribute to [Momentum's Discourse User Poll here](#{@poll_url}).

Your input is very important for Momentum to better understand men's Discourse experience. Please take a moment to give your input! The questions are all yes/no and should take you no more than 5 minutes to complete.

Once you take the poll, you will earn a [Discourse User Badge showing your Discourse User achievement level here](https://discourse.gomomentum.org/u/#{users_username}/badges), and you can [see all possible Momentum Badges that you can earn here](https://discourse.gomomentum.org/badges).

-- Your Momentum Moderators"

          send_private_message(from_username, voting_user['username'], message_subject, message_body)

        end
        next
      end
    end
  end
end

printf @field_settings, 'User', 'Poll', 'Does', '%', 'Score', '/', 'Max'


if @target_groups
  @target_groups.each do |group_plug|
    apply_to_group_users(group_plug, needs_user_client=true, skip_staged_user=true)
  end
else
  apply_to_all_users
end

puts "\n#{@sent_messages} user messages sent, #{@new_user_score_targets} new User Scores, and #{@user_not_voted_targets} Users Not yet voted out of #{@user_targets} possible targets out of #{@user_count} total users."
