require '../utility/momentum_api'

@do_live_updates = true
@instance = 'live' # 'live' or 'local'

# testing variables
@target_username = 'KM_Admin'  # David_Ashby, Ryan_Hyer,Stefan_Schmitz KM_Admin Kim_Miller
@issue_users = %w() # debug issue user_names

# poll parameters
@update_type = 'have_voted'  # have_voted, not_voted, both
@points_multiplier = 1.13
@users_score = 0
@max_points_possible = 0
@poll_url = 'https://discourse.gomomentum.org/t/user-persona-survey/6485/20'

# messages
@sent_messages = 0

# @user_option_targets = {
#     'theme_ids': [10]
# }

# @user_option_print = %w(
#     last_seen_at
#     last_posted_at
#     post_count
#     time_read
#     recent_time_read
#     theme_ids
# )

@target_post = 28707     # 28649
@target_polls = %w(version_two)  # basic new
@exclude_user_names = %w()  # js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin
@target_groups = %w(Mods)
@field_settings = "%-18s %-20s %-10s %-10s %-5s %-2s %-7s\n"

@user_count, @user_targets, @users_updated = 0, 0, 0, 0

# def print_user_options(user_details)
#   printf @field_settings, user_details['username'],
#          user_details[@user_option_print[0].to_s].to_s[0..9], user_details[@user_option_print[1].to_s].to_s[0..9],
#          user_details[@user_option_print[2].to_s], user_details[@user_option_print[3].to_s],
#          user_details[@user_option_print[4].to_s], user_details['user_option'][@user_option_print[5].to_s]
# end

# standardize_email_settings
def apply_function(client, voting_user)
  post = client.get_post(@target_post)
  polls = post['polls']
  users_username = client.api_username
  @user_count += 1

  polls.each do |poll|
    poll_name = poll['name']
    if @target_polls.include?(poll_name)
      poll_options = poll['options']

      begin
        poll_option_votes = client.voters(post_id: @target_post, poll_name: poll_name, api_username: users_username)['voters']

        if @update_type == 'have_voted' or @update_type == 'both'
          @user_targets += 1
          current_voter_votes = 0.0
          current_voter_points = 0.0
          current_question_point_value = 1.0
          max_points_possible = 0.0
          poll_options.each do |poll_option|
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
          current_voter_odd_percent = (current_voter_votes / poll['max']) * 100

          # @users_score = current_voter_points
          printf @field_settings, users_username, poll_name, current_voter_votes.to_int, current_voter_odd_percent.to_int,
                 current_voter_points.to_int, '/', max_points_possible.to_int

          # voter message details
          from_username = 'Kim_Miller'  # KM_Admin
          message_subject = "Thank You for Taking Momentum's Discourse User Poll"
          message_body = "Congratulations! Your Momentum Discourse User Score is #{current_voter_points.to_int} out of a maximum possible score of #{max_points_possible.to_int}.

In addition to your Discourse User Score of #{current_voter_points.to_int}, you have been assigned the Momentum Discourse Bronze and Silver User badges.

You can [retake the poll and receive a new score at anytime here](#{@poll_url}).

You can [see all the Discourse Badges you have earned here](https://discourse.gomomentum.org/u/#{users_username}/badges) and [all possible Momentum Badges that you can earn here](https://discourse.gomomentum.org/badges).

-- Your Momentum Moderators"

          send_private_message(from_username, voting_user['username'], message_subject, message_body)

        end

      rescue
        if @update_type == 'not_voted' or @update_type == 'both'
          @user_targets += 1
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


# client = connect_to_instance('KM_Admin')
# apply_function(client)

if @target_groups
  @target_groups.each do |group_plug|
    apply_to_group_users(group_plug, needs_user_client=true, skip_staged_user=true)
  end
else
  apply_to_all_users
end

puts "\n#{@sent_messages} user messages sent out of #{@user_targets} possible targets out of #{@user_count} total users."
