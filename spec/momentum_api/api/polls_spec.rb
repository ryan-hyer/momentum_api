require_relative '../../spec_helper'

describe MomentumApi::Poll do

  let(:user_details) { json_fixture("user_details.json") }
  let(:post_with_poll) { json_fixture("post_with_poll.json") }
  let(:poll_voters) { json_fixture("poll_voters.json") }
  let(:badge_grated) { json_fixture("badge_grated.json") }
  let(:poll_voters_error) { {"errors": ["poll_name is invalid"]} }

  let(:mock_user_client) do
    mock_user_client = instance_double('user_client')
    expect(mock_user_client).to receive(:get_post).once.and_return post_with_poll
    expect(mock_user_client).to receive(:poll_voters).once.and_return(poll_voters_error)
    mock_user_client
  end

  let(:mock_discourse) do
    mock_discourse = instance_double('discourse')
    expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
    expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
    mock_discourse
  end

  let(:mock_schedule) do
    mock_schedule = instance_double('schedule')
    expect(mock_schedule).to receive(:discourse).exactly(1).times.and_return(mock_discourse)
    mock_schedule
  end


  context '.run have_voted scan' do

    options_have_voted = schedule_options[:score_user_levels]
    options_have_voted[:update_type] = 'have_voted'

    let(:mock_user_client) do
      mock_user_client = instance_double('user_client')
      expect(mock_user_client).to receive(:get_post).once.and_return post_with_poll
      expect(mock_user_client).to receive(:poll_voters).once.and_return(poll_voters)
      mock_user_client
    end
    
    describe '.run init all' do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        # expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
        mock_discourse
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        # expect(mock_man).to receive(:discourse).exactly(1).times.and_return(mock_discourse)
        expect(mock_man).to receive(:user_details).exactly(6).times.and_return(user_details)
        expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
        expect(mock_man).to receive(:send_private_message).once.with('Kim_Miller', any_args)
        mock_man
      end

      let(:poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted) }

      it 'responds to run' do
        poll.run(mock_man)
        expect(poll).to respond_to(:run)
      end
    end

    describe '.run have_voted, but NOT new vote ' do

      let(:poll_voter_existing) { json_fixture("poll_voter_existing.json") }

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
        mock_discourse
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:discourse).exactly(1).times.and_return(mock_discourse)
        expect(mock_man).to receive(:user_details).exactly(4).times.and_return(poll_voter_existing)
        expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
        mock_man
      end

      let(:have_voted_poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted) }

      it 'finds voters vote and send message' do
        expect(have_voted_poll).to receive(:send_voted_message)
        have_voted_poll.run(mock_man)
        expect(have_voted_poll).to respond_to(:send_voted_message)
      end
    end


    context 'New vote' do

      let(:poll_voter_new) { json_fixture("poll_voter_new.json") }

      describe '.run init all' do

        let(:mock_discourse) do
          mock_discourse = instance_double('discourse')
          expect(mock_discourse).to receive(:options).exactly(2).times.and_return(discourse_options)
          expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
          mock_discourse
        end

        let(:mock_man) do
          mock_man = instance_double('man')
          expect(mock_man).to receive(:discourse).exactly(2).times.and_return(mock_discourse)
          expect(mock_man).to receive(:user_details).exactly(8).times.and_return(poll_voter_new)
          expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
          expect(mock_man).to receive(:send_private_message).once.with('Kim_Miller', any_args)
          expect(mock_man).to receive(:print_user_options).once
          mock_man
        end

        options_have_voted = schedule_options[:score_user_levels]
        options_have_voted[:update_type] = 'have_voted'
        let(:have_voted_poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted) }

        it 'finds voters vote and send message' do
          have_voted_poll.run(mock_man)
          expect(have_voted_poll).to respond_to(:run)
        end
      end

      describe '.run subcalls' do
        
        let(:mock_man) do
          mock_man = instance_double('man')
          expect(mock_man).to receive(:discourse).exactly(1).times.and_return(mock_discourse)
          expect(mock_man).to receive(:user_details).exactly(3).times.and_return(poll_voter_new)
          expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
          mock_man
        end

        options_have_voted = schedule_options[:score_user_levels]
        options_have_voted[:update_type] = 'have_voted'
        let(:have_voted_poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted) }

        it 'calls currect methods' do
          expect(have_voted_poll).to receive(:send_voted_message)
          expect(have_voted_poll).to receive(:update_user_profile_score)
          expect(have_voted_poll).to receive(:print_scored_user)
          have_voted_poll.run(mock_man)
          expect(have_voted_poll).to respond_to(:send_voted_message)
        end
      end


      describe '.run init all with do_live_update' do

        options_do_live_updates = discourse_options
        options_do_live_updates[:do_live_updates] = true

        let(:mock_discourse) do
          mock_discourse = instance_double('discourse')
          expect(mock_discourse).to receive(:options).twice.and_return(options_do_live_updates)
          expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
          mock_discourse
        end

        let(:mock_user_client) do
          mock_user_client = instance_double('user_client')
          expect(mock_user_client).to receive(:get_post).once.and_return post_with_poll
          expect(mock_user_client).to receive(:poll_voters).once.and_return(poll_voters)
          expect(mock_user_client).to receive(:user_badges).once.and_return([])    # todo sub correct return json
          expect(mock_user_client).to receive(:grant_user_badge).once.and_return(badge_grated)
          expect(mock_user_client).to receive(:update_user).once.and_return({"body": {"success": "OK"}})
          expect(mock_user_client).to receive(:user).once.and_return(poll_voter_new)
          mock_user_client
        end
        
        let(:mock_man) do
          mock_man = instance_double('man')
          expect(mock_man).to receive(:discourse).exactly(2).times.and_return(mock_discourse)
          expect(mock_man).to receive(:user_details).exactly(9).times.and_return(poll_voter_new)
          expect(mock_man).to receive(:user_client).exactly(6).times.and_return(mock_user_client)
          expect(mock_man).to receive(:print_user_options).exactly(2).times
          mock_man
        end

        options_have_voted = schedule_options[:score_user_levels]
        options_have_voted[:update_type] = 'have_voted'
        let(:have_voted_poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted) }

        it 'updates users profile and grant badge' do
          expect(have_voted_poll).to receive(:send_voted_message)
          # expect(have_voted_poll).to receive(:update_user_profile_score)
          expect(have_voted_poll).to receive(:print_scored_user)
          have_voted_poll.run(mock_man)
          expect(have_voted_poll).to respond_to(:send_voted_message)
        end
      end
      
    end

  end

  
  context '.run not_voted scan' do

    options_not_voted = schedule_options[:score_user_levels]
    options_not_voted[:update_type] = 'not_voted'

    describe '.run should init and respond' do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(3).times.and_return(user_details)
        expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
        expect(mock_man).to receive(:send_private_message).once.with('Kim_Miller', any_args)
        mock_man
      end

      let(:poll) { MomentumApi::Poll.new(mock_schedule, schedule_options[:score_user_levels]) }

      it 'responds to run as expected' do
        poll.run(mock_man)
        expect(poll).to respond_to(:run)
      end
    end
    
    describe '.run not_voted send message' do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end
      
      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(2).times.and_return(user_details)
        expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
        mock_man
      end

      let(:poll) { MomentumApi::Poll.new(mock_schedule, options_not_voted) }

      it 'call send_not_voted_message message' do
        expect(poll).to receive(:send_not_voted_message)
        poll.run(mock_man)
        expect(poll).to respond_to(:send_not_voted_message)
      end
    end


  end

end

