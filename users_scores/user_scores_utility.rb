$LOAD_PATH.unshift File.expand_path('../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../discourse_api/lib/discourse_api', __FILE__)


def print_user_options(user_details)
  printf @field_settings, user_details['username'],
         user_details[@user_option_print[0].to_s].to_s[0..9], user_details[@user_option_print[1].to_s].to_s[0..9],
         user_details[@user_option_print[2].to_s], user_details[@user_option_print[3].to_s],
         user_details[@user_option_print[4].to_s], user_details[@user_preferences][@user_option_print[5].to_s]
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


def update_user_profile_score(client, current_voter_points, user_details, users_username)
  @new_user_score_targets += 1
  # puts 'User Score to be updated'
  print_user_options(user_details)
  if @do_live_updates
    update_response = client.update_user(users_username, {"#{@user_preferences}": {"#{@user_score_field}": current_voter_points}})
    puts update_response[:body]['success']
    @users_updated += 1

    # check if update happened
    user_details_after_update = client.user(users_username)
    print_user_options(user_details_after_update)
    sleep(1)
  end
end

def update_badge(client, target_badge_name, badge_id, users_username)
  if @do_live_updates
    current_badges = client.user_badges(users_username)
    has_target_badge = false
    current_badges.each do |current_badge|
      if current_badge['name'] == target_badge_name
        has_target_badge = true
      end
    end
    if has_target_badge
      puts 'User already has badge'
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

def update_user_profile_badges(client, current_voter_points, user_details, users_username)
  @new_user_badge_targets += 1
  target_badge_name = nil
  # puts 'User Badges to be updated'
  # print_user_options(user_details)

  # calculate badges
  case current_voter_points
  when 0
    puts "You ran out of gas."
  when 1..7
    puts "Keep trying!"
  when 8..39
    target_badge_name = 'Beginner'
    puts target_badge_name
    update_badge(client, target_badge_name, 111, users_username)
  when 40..375
    target_badge_name = 'Intermediate'
    puts target_badge_name
    update_badge(client, target_badge_name, 110, users_username)
  when 376..1012
    target_badge_name = 'Advanced'
    puts target_badge_name
    update_badge(client, target_badge_name, 112, users_username)
  when  1013..10000
    target_badge_name = 'PowerUser'
    puts target_badge_name
    update_badge(client, target_badge_name, 113, users_username)
  else
    puts "Error: current_voter_points has an invalid value (#{current_voter_points})"
  end

  target_badge_name
  
end
