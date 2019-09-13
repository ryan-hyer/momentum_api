module MomentumApi
  class Messages

    def initialize(requestor, from_username, message_subject: nil, message_body: nil, mock: nil)
      raise ArgumentError, 'requestor needs to be defined' if requestor.nil?
      raise ArgumentError, 'from_username needs to be defined' if from_username.nil?

      # parameter setting
      @requestor          =   requestor
      @from_username      =   from_username
      @message_subject    =   message_subject
      @message_body       =   message_body
      @mock               =   mock

    end

    def send_private_message(man, message_body, message_subject=nil, from_username: nil, to_username: nil, cc_username: nil)
      raise ArgumentError, 'man needs to be defined' if man.nil?
      raise ArgumentError, 'message_body needs to be defined' if message_body.nil?
      raise ArgumentError, 'message_subject needs to be defined' if message_subject.nil?

      from_username = from_username || @from_username
      to_username = to_username || man.user_details['username']
      if cc_username  # todo add logic to removed any dupes?
        to_username = to_username + ',' + cc_username
      end

      # for testing only
      if from_username == to_username # and @from_username != 'KM_Admin'
        from_username = 'KM_Admin'
      end

      field_settings = "%-18s %-20s %-20s %-55s %-25s %-25s"
      message_detail = sprintf field_settings, '  Message From:', from_username, to_username, message_subject, message_body[0..20], 'Pending'
      man.discourse.options[:logger].info message_detail

      if man.discourse.options[:do_live_updates]
        from_client = man.discourse.connect_to_instance(from_username)

        response = from_client.create_private_message(
            title: message_subject,
            raw: message_body,
            target_usernames: to_username
        )
        @mock ? sleep(0) : sleep(1)

        # check if message sent - may be commented out
        created_message = from_client.get_post(response['id'])
        sent_message_detail = sprintf field_settings, '  Message From:', created_message['username'], to_username, created_message['topic_slug'], created_message['raw'][0..20], 'Sent'
        man.discourse.options[:logger].info sent_message_detail

        @requestor.counters[:'Messages Sent'] += 1
        @mock ? sleep(0) : sleep(1)
      end
    end

  end
end