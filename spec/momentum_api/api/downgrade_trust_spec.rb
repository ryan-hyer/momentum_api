require_relative '../../spec_helper'

describe MomentumApi::DowngradeTrust do

  let(:user_details_owner) { json_fixture("user_details.json") }
  let(:user_details_non_owner) { json_fixture("user_details_non_owner.json") }
  let(:admin_user_put) { json_fixture("admin_user_put.json") }

  user_options = schedule_options[:user]

  let(:mock_discourse) do
    mock_discourse = instance_double('discourse')
    expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
    expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
    mock_discourse
  end

  let(:mock_schedule) do
    mock_schedule = instance_double('schedule')
    expect(mock_schedule).to receive(:discourse).exactly(2).times.and_return(mock_discourse)
    mock_schedule
  end

  let(:mock_man) do
    mock_man = instance_double('man')
    expect(mock_man).to receive(:is_owner).exactly(1).times.and_return false
    expect(mock_man).to receive(:user_details).exactly(2).times.and_return(user_details_non_owner)
    mock_man
  end

  describe '.downgrade_trust_level' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      mock_dependencies
    end

    let(:user) { MomentumApi::DowngradeTrust.new(mock_schedule, user_options, mock: mock_dependencies) }

    context "init" do

      it ".downgrade_trust_level inits and responds" do
        expect(user).to respond_to(:run)
        user.run(mock_man)
      end
    end


    context "user already at correct trust level" do

      it "user leaves Update Targets updates" do
        expect(user).to respond_to(:run)
                user.run(mock_man)
        expect(user.instance_variable_get(:@counters)[:'User Trust Targets']).to eql(0)
      end
    end


    context "user needs to be downgraded" do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(2).times.and_return(discourse_options)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return(mock_discourse)
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(3).times.and_return(user_details_owner)
        expect(mock_man).to receive(:is_owner).exactly(1).times.and_return false
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end
      
      it "user Trust Targets updates" do
        expect(user).to respond_to(:run)
                user.run(mock_man)
        expect(user.instance_variable_get(:@counters)[:'User Trust Targets']).to eql(1)
      end
    end


    context "do_live_updates" do

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:user).once.and_return user_details_owner
        expect(mock_admin_client).to receive(:update_trust_level).once.and_return admin_user_put
        mock_admin_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:discourse).exactly(1).times.and_return(mock_discourse)
        expect(mock_man).to receive(:user_details).exactly(5).times.and_return(user_details_owner)
        expect(mock_man).to receive(:is_owner).exactly(1).times.and_return false
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:admin_client).twice.and_return(mock_admin_client)
        expect(mock_discourse).to receive(:options).exactly(3).times.and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(5).times.and_return(mock_discourse)
        mock_schedule
      end

      it "do_live_updates downgrade_trust_levels" do
        expect(user).to respond_to(:run)
        user.run(mock_man)
      end
    end


    context '.downgrade_trust_level sees issue user' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(4).times.and_return(user_details_owner)
        expect(mock_man).to receive(:is_owner).exactly(1).times.and_return false
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      discourse_options_issue_user = discourse_options
      discourse_options_issue_user[:issue_users] = %w(Tony_Christopher)

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).twice.and_return(discourse_options_issue_user)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return(mock_discourse)
        mock_schedule
      end

      it 'sees issue user' do
        expect { user.run(mock_man) }
            .to output(/Tony_Christopher in downgrade_trust_level/).to_stdout
      end
    end

  end
end

