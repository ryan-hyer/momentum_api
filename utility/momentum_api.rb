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
        end
      end
      starting_page_of_users += 1
    end
  end
end

def apply_to_group_users(client, group_plug)
  members = client.group_members(group_plug)
  members.each do |user|
    if @target_username
      if user['username'] == @target_username
        # @user_count += 1
        apply_function(client, user)
      end
    elsif not @exclude_user_names.include?(user['username'])
      # @user_count += 1
      # puts user['username']
      apply_function(client, user)
      sleep(1) # needs to be 2 in some cases
    end
  end
end
