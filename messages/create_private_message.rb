require '../utility/momentum_api'

@do_live_updates = true
client = connect_to_instance('live')   # 'live' or 'local'

# message from user name
client.api_username = 'Moe_Rubenzahl'
# message to group
group_plug = 'Tech'
# message
@message_subject = "Are you leaving Momentum?"
@message_body = "I noticed you did not renew your Momentum membership.

- If this was unintentional, you can [renew online](http://www.gomomentum.org/join). Do you need any help? Note that if the dues are a financial hardship, Momentum will assist. Contact me privately at moe1@rubenzahl.com to make arrangements.

- If you do intend to leave Momentum, it would be helpful for us to know why. Please answer [this brief survey](https://goo.gl/forms/10AslBf1jpR5X6aP2). lt will help us meet the needs of Momentum men.

Thank you for spending time with Momentum—I hope that you found some value in the experience. Let me know if I can be of assistance to you.

Moe Rubenzahl
Momentum Chief"

# testing variables
# @target_username = 'Kim_Miller'
@issue_users = %w() # debug issue user_names
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin)
@user_count, @sent_messages = 0, 0
@field_settings = "%-20s %-20s %-35s %-25s\n"

# standardize_email_settings
def apply_function(client, user)
  users_username = user['username']
  @user_count += 1
  # puts users_username

  if @do_live_updates
    response = client.create_private_message(
        title: @message_subject,
        raw: @message_body,
        target_usernames: users_username
    )

    # check if update happened
    created_message = client.get_post(response['id'])
    printf @field_settings, created_message['username'], users_username, created_message['topic_slug'],
           created_message['raw'][0..20]

    @sent_messages += 1
    sleep(1)
  end
end

printf @field_settings, 'Message From', 'Message To', 'Slug', 'Starting Text'

apply_to_group_users(client, group_plug)

puts "\n#{@sent_messages} messages sent for #{@user_count} users found."
