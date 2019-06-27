require_relative '../../spec_helper'

describe MomentumApi::Poll do

  let(:user_details) { json_fixture("user_details.json") }
  let(:post_with_poll) { json_fixture("post_with_poll.json") }
  let(:post_invalid_access) { json_fixture("post_invalid_access.json") }
  let(:poll_voters) { json_fixture("poll_voters.json") }
  let(:badge_grated) { json_fixture("badge_grated.json") }
  let(:badges_beginner) { json_fixture("badges_beginner.json") }
  let(:badges_intermediate) { json_fixture("badges_intermediate.json") }
  let(:poll_voters_error) { {"errors": ["poll_name is invalid"]} }

  let(:mock_dependencies) do
    mock_dependencies = instance_double('mock_dependencies')
    mock_dependencies
  end

  let(:mock_discourse) do
    mock_discourse = instance_double('discourse')
    expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
    mock_discourse
  end

  let(:mock_schedule) do
    mock_schedule = instance_double('schedule')
    expect(mock_schedule).to receive(:discourse).once.and_return(mock_discourse)
    mock_schedule
  end


  context '.run have_voted scan' do

    options_have_voted = schedule_options[:user_scores]
    options_have_voted[:update_type] = 'have_voted'

    let(:mock_user_client) do
      mock_user_client = instance_double('user_client')
      expect(mock_user_client).to receive(:get_post).once.and_return post_with_poll
      expect(mock_user_client).to receive(:poll_voters).once.and_return(poll_voters)
      mock_user_client
    end

    let(:mock_man) do
      mock_man = instance_double('man')
      expect(mock_man).to receive(:user_details).exactly(7).times.and_return(user_details)
      expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
      mock_man
    end

    describe '.run init and send_private_message' do

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:send_private_message).once
                                         .with(mock_man, any_args, /Thank You for Taking/)
        mock_dependencies
      end

      let(:poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted, mock: mock_dependencies) }

      it 'responds to run' do
        expect(poll).to respond_to(:run)
        poll.run(mock_man)
      end
    end


    describe '.run init with no poll' do

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:send_private_message).once
                                         .with(mock_man, any_args, /Thank You for Taking/)
        mock_dependencies
      end

      options_default_poll = schedule_options[:user_scores]
      options_default_poll[:update_type] = 'have_voted'
      options_default_poll[:target_polls] = nil
      let(:poll) { MomentumApi::Poll.new(mock_schedule, options_default_poll, mock: mock_dependencies) }

      it 'responds to run and finds default poll' do
        expect(poll).to respond_to(:run)
        poll.run(mock_man)
      end
    end


    context 'Existing vote' do

      let(:poll_voter_existing) { json_fixture("poll_voter_existing.json") }

      describe '.run Existing voter ' do

        let(:mock_discourse) do
          mock_discourse = instance_double('discourse')
          expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
          expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
          mock_discourse
        end

        let(:mock_man) do
          mock_man = instance_double('man')
          expect(mock_man).to receive(:discourse).once.and_return(mock_discourse)
          expect(mock_man).to receive(:user_details).exactly(5).times.and_return(poll_voter_existing)
          expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
          mock_man
        end

        let(:have_voted_poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted, mock: mock_dependencies) }

        it 'finds voters vote and send message' do
          expect(have_voted_poll).to receive(:send_voted_message)
          expect(have_voted_poll).to respond_to(:send_voted_message)
          have_voted_poll.run(mock_man)
        end
      end


      describe '.run Existing voter, Has badge, do_live_update' do

        options_do_live_updates = discourse_options
        options_do_live_updates[:do_live_updates] = true

        let(:mock_admin_client) do
          mock_admin_client = instance_double('admin_client')
          expect(mock_admin_client).to receive(:user_badges).once.and_return(badges_intermediate)
          mock_admin_client
        end

        let(:mock_discourse) do
          mock_discourse = instance_double('discourse')
          expect(mock_discourse).to receive(:options).once.and_return(options_do_live_updates)
          expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
          expect(mock_discourse).to receive(:admin_client).once.and_return(mock_admin_client)
          mock_discourse
        end

        let(:mock_user_client) do
          mock_user_client = instance_double('user_client')
          expect(mock_user_client).to receive(:get_post).once.and_return post_with_poll
          expect(mock_user_client).to receive(:poll_voters).once.and_return(poll_voters)
          mock_user_client
        end

        let(:mock_man) do
          mock_man = instance_double('man')
          expect(mock_man).to receive(:discourse).twice.and_return(mock_discourse)
          expect(mock_man).to receive(:user_details).exactly(5).times.and_return(poll_voter_existing)
          expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
          mock_man
        end

        options_have_voted = schedule_options[:user_scores]
        options_have_voted[:update_type] = 'have_voted'
        let(:have_voted_poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted, mock: mock_dependencies) }

        it 'updates users profile and grant badge' do
          expect(have_voted_poll).to receive(:send_voted_message)
          expect(have_voted_poll).to receive(:print_scored_user)
          expect(have_voted_poll).to respond_to(:send_voted_message)
          have_voted_poll.run(mock_man)
        end
      end

    end


    context 'New vote' do

      let(:poll_voter_new) { json_fixture("poll_voter_new.json") }


      describe '.run init all' do

        let(:mock_discourse) do
          mock_discourse = instance_double('discourse')
          expect(mock_discourse).to receive(:options).twice.and_return(discourse_options)
          expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
          mock_discourse
        end

        let(:mock_man) do
          mock_man = instance_double('man')
          expect(mock_man).to receive(:discourse).twice.and_return(mock_discourse)
          expect(mock_man).to receive(:user_details).exactly(7).times.and_return(poll_voter_new)
          expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
          expect(mock_man).to receive(:print_user_options).once
          mock_man
        end

        let(:have_voted_poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted, mock: mock_dependencies) }

        it 'finds voters vote and send message' do
          expect(have_voted_poll).to receive(:send_voted_message)
          expect(have_voted_poll).to respond_to(:send_voted_message)
          have_voted_poll.run(mock_man)
        end
      end


      describe '.run subcalls' do

        let(:mock_discourse) do
          mock_discourse = instance_double('discourse')
          expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
          expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
          mock_discourse
        end

        let(:mock_man) do
          mock_man = instance_double('man')
          expect(mock_man).to receive(:discourse).once.and_return(mock_discourse)
          expect(mock_man).to receive(:user_details).exactly(4).times.and_return(poll_voter_new)
          expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
          mock_man
        end

        options_have_voted = schedule_options[:user_scores]
        options_have_voted[:update_type] = 'have_voted'
        let(:have_voted_poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted, mock: mock_dependencies) }

        it 'calls currect methods' do
          expect(have_voted_poll).to receive(:send_voted_message)
          expect(have_voted_poll).to receive(:update_user_profile_score)
          expect(have_voted_poll).to receive(:print_scored_user)
          expect(have_voted_poll).to respond_to(:send_voted_message)
          have_voted_poll.run(mock_man)
        end
      end


      describe '.run has_man_voted?' do

        let(:mock_dependencies) do
          mock_dependencies = instance_double('mock_dependencies')
          mock_dependencies
        end
        
        let(:mock_user_client) do
          mock_user_client = instance_double('user_client')
          expect(mock_user_client).to receive(:get_post).once.and_return post_with_poll
          expect(mock_user_client).to receive(:poll_voters).once
                                          .and_raise(DiscourseApi::TooManyRequests.new('error message here'))
          expect(mock_user_client).to receive(:poll_voters).once.and_return(poll_voters)
          mock_user_client
        end

        let(:mock_discourse) do
          mock_discourse = instance_double('discourse')
          expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
          expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
          mock_discourse
        end

        let(:mock_man) do
          mock_man = instance_double('man')
          expect(mock_man).to receive(:discourse).once.and_return(mock_discourse)
          expect(mock_man).to receive(:user_details).exactly(5).times.and_return(poll_voter_new)
          expect(mock_man).to receive(:user_client).exactly(3).times.and_return(mock_user_client)
          mock_man
        end

        options_have_voted = schedule_options[:user_scores]
        options_have_voted[:update_type] = 'have_voted'
        let(:have_voted_poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted, mock: mock_dependencies) }

        it 'handles TooManyRequests and tries again' do
          expect(have_voted_poll).to receive(:update_user_profile_score)
          expect(have_voted_poll).to receive(:print_scored_user)
          expect(have_voted_poll).to receive(:send_voted_message)
          have_voted_poll.run(mock_man)
        end
      end


      describe '.run get_poll_post' do

        let(:mock_dependencies) do
          mock_dependencies = instance_double('mock_dependencies')
          mock_dependencies
        end

        let(:mock_user_client) do
          mock_user_client = instance_double('user_client')
          expect(mock_user_client).to receive(:get_post).once
                                          .and_raise(DiscourseApi::TooManyRequests.new('error message here'))
          expect(mock_user_client).to receive(:get_post).once.and_return post_with_poll
          expect(mock_user_client).to receive(:poll_voters).once.and_return(poll_voters)
          mock_user_client
        end

        let(:mock_discourse) do
          mock_discourse = instance_double('discourse')
          expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
          expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
          mock_discourse
        end

        let(:mock_man) do
          mock_man = instance_double('man')
          expect(mock_man).to receive(:discourse).once.and_return(mock_discourse)
          expect(mock_man).to receive(:user_details).exactly(4).times.and_return(poll_voter_new)
          expect(mock_man).to receive(:user_client).exactly(3).times.and_return(mock_user_client)
          mock_man
        end

        options_have_voted = schedule_options[:user_scores]
        options_have_voted[:update_type] = 'have_voted'
        let(:have_voted_poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted, mock: mock_dependencies) }

        it 'handles TooManyRequests and tries again' do
          expect(have_voted_poll).to receive(:update_user_profile_score)
          expect(have_voted_poll).to receive(:print_scored_user)
          expect(have_voted_poll).to receive(:send_voted_message)
          have_voted_poll.run(mock_man)
        end
      end


      describe '.run New voter, needs badge, do_live_update' do

        options_do_live_updates = discourse_options
        options_do_live_updates[:do_live_updates] = true

        let(:mock_admin_client) do
          mock_admin_client = instance_double('admin_client')
          expect(mock_admin_client).to receive(:user_badges).once.and_return(badges_beginner)
          expect(mock_admin_client).to receive(:grant_user_badge).once.and_return(badge_grated)
          expect(mock_admin_client).to receive(:update_user).once.and_return({"body": {"success": "OK"}})
          expect(mock_admin_client).to receive(:user).once.and_return(poll_voter_new)
          mock_admin_client
        end

        let(:mock_discourse) do
          mock_discourse = instance_double('discourse')
          expect(mock_discourse).to receive(:options).twice.and_return(options_do_live_updates)
          expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
          expect(mock_discourse).to receive(:admin_client).exactly(4).times.and_return(mock_admin_client)
          mock_discourse
        end

        let(:mock_user_client) do
          mock_user_client = instance_double('user_client')
          expect(mock_user_client).to receive(:get_post).once.and_return post_with_poll
          expect(mock_user_client).to receive(:poll_voters).once.and_return(poll_voters)
          mock_user_client
        end
        
        let(:mock_man) do
          mock_man = instance_double('man')
          expect(mock_man).to receive(:discourse).exactly(6).times.and_return(mock_discourse)
          expect(mock_man).to receive(:user_details).exactly(10).times.and_return(poll_voter_new)
          expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
          expect(mock_man).to receive(:print_user_options).twice
          mock_man
        end

        options_newly_voted = schedule_options[:user_scores]
        options_newly_voted[:update_type] = 'newly_voted'
        let(:have_voted_poll) { MomentumApi::Poll.new(mock_schedule, options_newly_voted, mock: mock_dependencies) }

        it 'updates users profile and grant badge' do
          expect(have_voted_poll).to receive(:send_voted_message)
          expect(have_voted_poll).to receive(:print_scored_user)
          expect(have_voted_poll).to respond_to(:send_voted_message)
          have_voted_poll.run(mock_man)
        end
      end

    end

  end

  
  context '.run not_voted scan' do

    options_not_voted = schedule_options[:user_scores]
    options_not_voted[:update_type] = 'not_voted'

    let(:mock_user_client_not_voted) do
      mock_user_client = instance_double('user_client')
      expect(mock_user_client).to receive(:get_post).once.and_return post_with_poll
      expect(mock_user_client).to receive(:poll_voters).once
                                      .and_raise(DiscourseApi::UnprocessableEntity.new(post_invalid_access))
      mock_user_client
    end


    describe '.run should init and send_private_message' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(5).times.and_return(user_details)
        expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client_not_voted)
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:send_private_message).once
                                         .with(mock_man, any_args)
                                         # .with(mock_man, any_args, /What's Your Score?/)
        mock_dependencies
      end

      let(:poll) { MomentumApi::Poll.new(mock_schedule, options_not_voted, mock: mock_dependencies) }

      it 'responds to run as expected' do
        expect(poll).to respond_to(:run)
        poll.run(mock_man)
      end
    end
    

    describe '.run send_not_voted_message' do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end
      
      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(3).times.and_return(user_details)
        expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client_not_voted)
        mock_man
      end

      let(:poll) { MomentumApi::Poll.new(mock_schedule, options_not_voted, mock: mock_dependencies) }

      it 'call send_not_voted_message message' do
        expect(poll).to receive(:send_not_voted_message)
        expect(poll).to respond_to(:send_not_voted_message)
        poll.run(mock_man)
      end
    end


    describe '.run :poll_voters returns nill' do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(3).times.and_return(user_details)
        expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client_not_voted)
        mock_man
      end

      let(:poll) { MomentumApi::Poll.new(mock_schedule, options_not_voted, mock: mock_dependencies) }

      it '.poll_voters returns nil to show user has not voted' do
        expect(poll).to receive(:send_not_voted_message)
        expect(poll).to respond_to(:send_not_voted_message)
        poll.run(mock_man)      end
    end

  end


  context '.run get_post errors found' do

    options_not_voted = schedule_options[:user_scores]
    options_not_voted[:update_type] = 'not_voted'


    describe '.run :get_post should just keep going to to next man' do

      let(:mock_user_client) do
        mock_user_client = instance_double('user_client')
        expect(mock_user_client).to receive(:get_post).once
                                        .and_raise(DiscourseApi::UnauthenticatedError.new(post_invalid_access))
        mock_user_client
      end
      
      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).twice.and_return(user_details)
        expect(mock_man).to receive(:user_client).once.and_return(mock_user_client)
        mock_man
      end

      let(:poll) { MomentumApi::Poll.new(mock_schedule, options_not_voted, mock: mock_dependencies) }

      it '.get_post exits gracefully' do
        poll.run(mock_man)
      end
    end

  end


  context '.update_user_profile_badges' do

    options_have_voted = schedule_options[:user_scores]
    options_have_voted[:update_type] = 'have_voted'


    describe '.update_user_profile_badges case current_voter_points' do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:poll) { MomentumApi::Poll.new(mock_schedule, options_have_voted, mock: mock_dependencies) }

      it '.update_user_profile_badges grants correct bage' do
        poll.update_user_profile_badges(4)
      end

      it 'grants correct bage' do
        expect(poll).to receive(:update_badge).with('Beginner', 111)
        expect(poll).to respond_to(:update_badge)
        poll.update_user_profile_badges(20)
      end

      it 'grants correct bage' do
        expect(poll).to receive(:update_badge).with('Intermediate', 110)
        expect(poll).to respond_to(:update_badge)
        poll.update_user_profile_badges(200)
      end

      it 'grants correct bage' do
        expect(poll).to receive(:update_badge).with('Advanced', 112)
        expect(poll).to respond_to(:update_badge)
        poll.update_user_profile_badges(500)
      end

      it 'grants correct bage' do
        expect(poll).to receive(:update_badge).with('PowerUser', 113)
        expect(poll).to respond_to(:update_badge)
        poll.update_user_profile_badges(1015)
      end

      it 'errors on invalud score' do
        expect { poll.update_user_profile_badges('abc') }
            .to output(/Error/).to_stdout
      end

    end

  end

end
