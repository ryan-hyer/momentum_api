module MomentumApi
  module Messages

    def initialize(post_id)
      raise ArgumentError, 'post_id needs to be defined' if post_id.nil?
    end

    def send_private_message(from_username, message_subject, message_body)
      to_username = @user_details['username']
      if from_username == to_username and from_username != 'KM_Admin'
        from_username = 'KM_Admin'
      end
      from_client = connect_to_instance(from_username)

      field_settings = "%-18s %-20s %-20s %-55s %-25s %-25s\n"
      printf field_settings, '  Message From:', from_client.api_username, to_username, message_subject, message_body[0..20], 'Pending'

      if @discourse.options[:do_live_updates]
        response = from_client.create_private_message(
            title: message_subject,
            raw: message_body,
            target_usernames: to_username
        )

        # check if message sent
        created_message = from_client.get_post(response['id'])
        printf field_settings, '  Message From:', created_message['username'], to_username, created_message['topic_slug'], created_message['raw'][0..20], 'Sent'

        @discourse_counters[:'Messages Sent'] += 1
        sleep(1)
      end
    end

  end
end