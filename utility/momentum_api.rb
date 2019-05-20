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

def apply_to_all_users(needs_user_client=false)
  @skipped_users = 0
  # @user_count = 0
  starting_page_of_users = 1
  while starting_page_of_users > 0
    # puts 'Top While'
    client = connect_to_instance('KM_Admin')
    @users = client.list_users('active', page: starting_page_of_users)
    if @users.empty?
      starting_page_of_users = 0
    else
      # puts "Page .................. #{starting_page_of_users}"
      @users.each do |user|
        if @target_username
          if user['username'] == @target_username
            # @user_count += 1
            if needs_user_client
              client = connect_to_instance(user['username'])
            end
            apply_function(client, user)
          end
        elsif not @exclude_user_names.include?(user['username']) and user['active'] == true
          # @user_count += 1
          if needs_user_client
            client = connect_to_instance(user['username'])
          end
          apply_function(client, user)
          sleep(1) # needs to be 2 in some cases
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
        # admin_client = connect_to_instance('KM_Admin')
        full_user = admin_client.user(user['username'])
        # puts full_user['staged']
        staged = full_user['staged']
      end
    end
    if staged
      puts 'Skipping staged user'
    else
      if @target_username
        if user['username'] == @target_username
          # @user_count += 1
          if needs_user_client
            # client = connect_to_instance(user['username'])
            apply_function(connect_to_instance(user['username']), user)
            # apply_function(connect_to_instance(user['username']), user, group_plug=group_plug)
          else
            apply_function(admin_client, user)
            # apply_function(admin_client, user, group_plug=group_plug)
          end
          # apply_function(client, user)
        end
      elsif not @exclude_user_names.include?(user['username'])
        # @user_count += 1
        # puts user['username']
        if needs_user_client
          # client = connect_to_instance(user['username'])
          apply_function(connect_to_instance(user['username']), user)
        else
          apply_function(admin_client, user)
        end
        # apply_function(client, user)
        sleep(1) # needs to be 2 in some cases
      end
    end
  end
end


def send_private_message(from_username, to_username, message_subject, message_body)
  from_client = connect_to_instance(from_username)
  # users_username = to_user['username']
  field_settings = "%-18s %-20s %-20s %-55s %-25s %-25s\n"
  # printf field_settings, 'Message From', 'Message To', 'Slug', 'Starting Text', 'Status'
  printf field_settings, '  Message From:', from_client.api_username, to_username, message_subject, message_body[0..20], 'Pending'

  if @do_live_updates
    response = from_client.create_private_message(
        title: message_subject,
        raw: message_body,
        target_usernames: to_username
    )

    # check if update happened
    created_message = from_client.get_post(response['id'])
    printf field_settings, created_message['username'], to_username, created_message['topic_slug'], created_message['raw'][0..20], 'Sent'

    @sent_messages += 1
    sleep(1)
  end
end
