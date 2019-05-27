$LOAD_PATH.unshift File.expand_path('../../../discourse_api/lib', __FILE__)
require File.expand_path('../../../discourse_api/lib/discourse_api', __FILE__)

def connect_to_instance(api_username, instance=@instance)
  # @admin_client = 'KM_Admin'
  client = ''
  case instance
  when 'live'
    client = DiscourseApi::Client.new('https://discourse.gomomentum.org/')
    client.api_key = ENV['REMOTE_DISCOURSE_API']
    # puts 'Live'
    # puts ENV['REMOTE_DISCOURSE_API']
  when 'local'
    client = DiscourseApi::Client.new('http://localhost:3000')
    client.api_key = ENV['LOCAL_DISCOURSE_API']
  else
    puts 'Host unknown'
  end
  client.api_username = api_username
  client
end

def apply_call(admin_client, needs_user_client, user)
  # puts user['username']
  @user_count += 1
  if needs_user_client
    user_client = connect_to_instance(user['username'])
    apply_function(user, admin_client, user_client)
  else
    apply_function(user, admin_client)
  end
end

def apply_to_all_users(needs_user_client=false, admin_username='KM_Admin')
  starting_page_of_users = 1
  while starting_page_of_users > 0
    admin_client = connect_to_instance(admin_username)
    @users = admin_client.list_users('active', page: starting_page_of_users)
    if @users.empty?
      starting_page_of_users = 0
    else
      @users.each do |user|
        if @target_username
          if user['username'] == @target_username
            apply_call(admin_client, needs_user_client, user)
          end
        elsif not @exclude_user_names.include?(user['username']) and user['active'] == true
          printf "%-15s %s \r", 'Scanning User: ', @user_count
          apply_call(admin_client, needs_user_client, user)
        else
          @skipped_users += 1
        end
      end
      starting_page_of_users += 1
    end
  end
end

def apply_to_group_users(group_plug, needs_user_client=false, skip_staged_user=false, admin_username='KM_Admin')
  admin_client = connect_to_instance(admin_username)
  members = admin_client.group_members(group_plug)
  members.each do |user|
    staged = false
    if skip_staged_user
      if user['last_seen_at']
        staged = false
      else
        full_user = admin_client.user(user['username'])
        staged = full_user['staged']
      end
    end
    if staged
      # puts "Skipping staged user #{user['username']}"
    else
      if @target_username
        if user['username'] == @target_username
          apply_call(admin_client, needs_user_client, user)
        end
      elsif not @exclude_user_names.include?(user['username'])
        if @issue_users.include?(user['username'])
          puts "#{user['username']} in apply_to_group_users method"
        end
        printf "%-15s %s \r", 'Scanning User: ', @user_count
        apply_call(admin_client, needs_user_client, user)
      end
    end
  end
end


def send_private_message(from_username, to_username, message_subject, message_body, do_live_updates)
  if from_username == to_username and from_username != 'KM_Admin'
    from_username = 'KM_Admin'
  end
  from_client = connect_to_instance(from_username)

  field_settings = "%-18s %-20s %-20s %-55s %-25s %-25s\n"
  printf field_settings, '  Message From:', from_client.api_username, to_username, message_subject, message_body[0..20], 'Pending'

  if do_live_updates
    response = from_client.create_private_message(
        title: message_subject,
        raw: message_body,
        target_usernames: to_username
    )

    # check if update happened
    created_message = from_client.get_post(response['id'])
    printf field_settings, '  Message From:', created_message['username'], to_username, created_message['topic_slug'], created_message['raw'][0..20], 'Sent'

    @sent_messages += 1
    sleep(1)
  end
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


