$LOAD_PATH.unshift File.expand_path('../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../discourse_api/lib/discourse_api', __FILE__)


def print_user_options(user_details)
  printf @field_settings, user_details['username'],
         user_details[@user_option_print[0].to_s].to_s[0..9], user_details[@user_option_print[1].to_s].to_s[0..9],
         user_details[@user_option_print[2].to_s], user_details[@user_option_print[3].to_s],
         user_details[@user_option_print[4].to_s], user_details[@user_preferences][@user_option_print[5].to_s]
end


def score_voter(poll, poll_option_votes, users_username)
  @user_targets += 1
  current_voter_votes = 0.0
  current_voter_points_float = 0.0
  current_question_point_value = 1.0
  max_points_possible = 0.0
  poll['options'].each do |poll_option|
    if poll_option_votes[poll_option['id']]
      option_votes = poll_option_votes[poll_option['id']]
      option_votes.each do |vote|
        if vote['username'] == users_username
          # puts vote['username'], poll_option['html']
          current_voter_votes += 1
          current_voter_points_float = current_voter_points_float + current_question_point_value
        end
      end
    end
    max_points_possible = max_points_possible + current_question_point_value
    current_question_point_value = current_question_point_value * @points_multiplier
  end
  current_voter_points = current_voter_points_float.to_int
  current_voter_odd_percent = (current_voter_votes / poll['max']) * 100

  printf @field_settings, users_username, poll['name'], current_voter_votes.to_int, current_voter_odd_percent.to_int,
         current_voter_points, '/', max_points_possible.to_int

  return current_voter_points, max_points_possible
end


def update_user_profile_score(client, current_voter_points, user_details, users_username)
  @new_user_score_targets += 1
  puts 'User Score to be updated'
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

def update_user_profile_badges(client, current_voter_points, user_details, users_username)
  @new_user_badge_targets += 1
  target_badge_name = nil
  puts 'User Badges to be updated'
  print_user_options(user_details)

  # calculate badges
  case current_voter_points
  when 0
    puts "You ran out of gas."
  when 1..8
    puts "Beginner"
    target_badge_name = 'Beginner'
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
      puts 'User needs badge'
    end
  when 9..35
    puts "Intermediate"
  when 36..377
    puts "Advanced"
  when 426..10000
    puts "PowerUser"
  else
    puts "Error: current_voter_points has an invalid value (#{current_voter_points})"
  end

  if @do_live_updates
    update_response = client.update_user(users_username, {"#{@user_preferences}": {"#{@user_score_field}": current_voter_points}})
    puts update_response[:body]['success']
    @users_updated += 1

    # check if update happened
    user_details_after_update = client.user(users_username)
    print_user_options(user_details_after_update)
    sleep(1)
  end

  target_badge_name
  
end
