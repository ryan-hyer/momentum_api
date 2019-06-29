require_relative '../../spec_helper'

describe MomentumApi::Messages do

  let(:user_details) { json_fixture("user_details.json") }
  let(:private_message_create) { json_fixture("private_message_create.json") }
  let(:private_message_get) { json_fixture("private_message_get.json") }
  let(:message_subject) { 'Test Message Subject' }
  let(:message_body) { 'Test Message Body ...' }

  let(:mock_discourse) do
    mock_discourse = instance_double('discourse')
    expect(mock_discourse).to receive(:options).exactly(2).times.and_return(discourse_options)
    mock_discourse
  end

  let(:mock_man) do
    mock_man = instance_double('man')
    expect(mock_man).to receive(:user_details).once.times.and_return(user_details)
    expect(mock_man).to receive(:discourse).exactly(2).times.and_return(mock_discourse)
    mock_man
  end

  describe '.send_private_message' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      mock_dependencies
    end

    let(:messages) { MomentumApi::Messages.new(mock_dependencies, 'Kim_Miller' )}

    describe "init message master" do

      it ".send_private_message inits and responds" do
        expect(messages).to respond_to(:send_private_message)
        messages.send_private_message(mock_man, message_subject, message_body)
      end
    end
  end


  context '.send_private_message do_live_updates' do

    options_do_live_updates = discourse_options
    options_do_live_updates[:do_live_updates] = true

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:counters).and_return({'Messages Sent': 0})
      mock_dependencies
    end

    let(:mock_user_client) do
      mock_user_client = instance_double('user_client')
      expect(mock_user_client).to receive(:create_private_message).once.with(
          title: 'Test Message Subject', raw: 'Test Message Body ...', target_usernames: 'Tony_Christopher')
                                      .and_return private_message_create
      expect(mock_user_client).to receive(:get_post).once.with(any_args).and_return private_message_get
      mock_user_client
    end

    let(:mock_discourse) do
      mock_discourse = instance_double('discourse')
      expect(mock_discourse).to receive(:connect_to_instance).once.and_return(mock_user_client)
      expect(mock_discourse).to receive(:options).exactly(3).times.and_return(options_do_live_updates)
      mock_discourse
    end
    
    let(:mock_man) do
      mock_man = instance_double('man')
      expect(mock_man).to receive(:user_details).once.times.and_return(user_details)
      expect(mock_man).to receive(:discourse).exactly(4).times.and_return(mock_discourse)
      mock_man
    end

    describe '.send_private_message from same as to' do

      let(:messages) { MomentumApi::Messages.new(mock_dependencies, 'Kim_Miller' )}

      it "sends message" do
        expect(messages).to respond_to(:send_private_message)
        messages.send_private_message(mock_man, message_body, message_subject)
      end
    end

    describe '.send_private_message from same as to' do

      let(:messages) { MomentumApi::Messages.new(mock_dependencies, 'Tony_Christopher' )}

      it ".send_private_message inits and changes from to 'KM_Admin'" do
        expect(messages).to respond_to(:send_private_message)
        expect {  messages.send_private_message(mock_man, message_body, message_subject) }
            .to output(/KM_Admin/).to_stdout
      end
    end

    describe '.send_private_message from same as to' do

      let(:messages) { MomentumApi::Messages.new(mock_dependencies, 'Tony_Christopher' )}

      it ".send_private_message inits and changes from to 'KM_Admin'" do
        expect(messages).to respond_to(:send_private_message)
        expect {  messages.send_private_message(mock_man, message_body, message_subject) }
            .to output(/KM_Admin/).to_stdout
      end
    end
    
  end

end