require '../utility/momentum_api'

@do_live_updates = false
@from_username = 'Moe_Rubenzahl'
@instance = 'live'
client = connect_to_instance('KM_Admin')   # 'live' or 'local'

# message from user name
client.api_username = @from_username
# message to group
group_plug = 'OwnerExpired'
# message
@message_subject = "We are sorry to see you go"
@message_body = "I sent you a message last month about your expired Momentum membership asking you to either:

- [Re-join online here.](http://www.gomomentum.org/join)

   or

- Take [Momentum's exit survey here](https://goo.gl/forms/10AslBf1jpR5X6aP2) to help us learn more about your choice to leave Momentum.

If money is an issue, remember that Momentum provides scholarships where needed. Contact me privately at moe1@rubenzahl.com to make arrangements.

Thank you for spending time with Momentum, and thank you for going the final mile so we may have a proper completion if that is your intention.

Moe Rubenzahl
Momentum Chief"

# testing variables
# @target_username = 'Kim_Miller'
@issue_users = %w() # debug issue user_names
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin)
@user_count, @sent_messages = 0, 0
@field_settings = "%-20s %-20s %-35s %-25s %-25s\n"

# standardize_email_settings
def apply_function(client, user)
  users_username = user['username']
  @user_count += 1
  printf @field_settings, @from_username, users_username, @message_subject, @message_body[0..20], 'Pending'
  
  if @do_live_updates
    response = client.create_private_message(
        title: @message_subject,
        raw: @message_body,
        target_usernames: users_username
    )

    # check if update happened
    created_message = client.get_post(response['id'])
    printf @field_settings, created_message['username'], users_username, created_message['topic_slug'],
           created_message['raw'][0..20], 'Sent'

    @sent_messages += 1
    sleep(1)
  end
end

printf @field_settings, 'Message From', 'Message To', 'Slug', 'Starting Text', 'Status'

apply_to_group_users(client, group_plug)

puts "\n#{@sent_messages} messages sent for #{@user_count} users found."
