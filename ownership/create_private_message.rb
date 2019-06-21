require '../utility/momentum_api'

@do_live_updates = false
@instance = 'live'
@emails_from_username = 'Kim_Miller'  # 'Moe_Rubenzahl'
# client = connect_to_instance('KM_Admin')   # 'live' or 'local'
# message from user name
# client.api_username = @emails_from_username

# message to group
group_plug = 'Mods'  # OwnerExpired
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
# @target_username = 'KM_Admin'
@issue_users = %w() # debug issue user_names
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin)
zero_counters
@field_settings = "%-20s %-20s %-35s %-25s %-25s\n"


# standardize_email_settings
def apply_function(user, admin_client, user_client='', group_plug='All')
  send_private_message(@emails_from_username, to_user['username'], @message_subject, @message_body, do_live_updates=false)
end

printf @field_settings, 'Message From', 'Message To', 'Slug', 'Starting Text', 'Status'

apply_to_group_users(group_plug, needs_user_client=false, skip_staged_user=false, admin_user=@emails_from_username)

# puts "\n#{@sent_messages} messages sent for #{@user_count} users found."
scan_summary
