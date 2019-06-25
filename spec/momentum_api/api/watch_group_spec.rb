require_relative '../../spec_helper'

describe MomentumApi::WatchGroup do

  let(:user_details_group_watching) { json_fixture("user_details_group_watching.json") }
  let(:user_details_group_not_watching) { json_fixture("user_details_group_not_watching.json") }
  let(:group_committed) { json_fixture("group_committed.json") }
  let(:category_committed_not_watching) { json_fixture("category_committed_not_watching.json") }
  let(:categories) { json_fixture("categories.json") }
  let(:category_committed_watching) { json_fixture("category_committed_watching.json") }

  watching_options = schedule_options[:watching]

  let(:mock_discourse) do
    mock_discourse = instance_double('discourse')
    expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
    expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
    mock_discourse
  end

  let(:mock_schedule) do
    mock_schedule = instance_double('schedule')
    expect(mock_schedule).to receive(:discourse).twice.and_return(mock_discourse)
    mock_schedule
  end

  let(:mock_man) do
    mock_man = instance_double('man')
    expect(mock_man).to receive(:user_details).exactly(3).times.and_return(user_details_group_watching)
    mock_man
  end

  describe '.run' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      mock_dependencies
    end

    let(:watch_group) { MomentumApi::WatchGroup.new(mock_schedule, watching_options, mock: mock_dependencies) }

    context "init" do
      
      it ".run inits and responds" do
        expect(watch_group).to respond_to(:run)
        watch_group.run(mock_man, group_committed)
      end
    end


    context "group already at default" do

      # let(:mock_man) do
      #   mock_man = instance_double('man')
      #   expect(mock_man).to receive(:user_details).exactly(2).times.and_return(user_details_group_watching)
      #   mock_man
      # end

      it "Category Update Targets updates" do
        expect(watch_group).to respond_to(:run)
                watch_group.run(mock_man, group_committed)
        expect(watch_group.instance_variable_get(:@counters)[:'Group Update Targets']).to eql(0)
      end
    end


    context "group not at default" do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).twice.and_return(mock_discourse)
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(3).times.and_return(user_details_group_not_watching)
        mock_man
      end

      it "Category Update Targets updates" do
        expect(watch_group).to respond_to(:run)
                watch_group.run(mock_man, group_committed)
        expect(watch_group.instance_variable_get(:@counters)[:'Group Update Targets']).to eql(1)
      end
    end


    context "do_live_updates" do

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:user).once.and_return user_details_group_watching
        expect(mock_admin_client).to receive(:group_set_user_notify_level).once
        mock_admin_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(5).times.and_return(user_details_group_not_watching)
        mock_man
      end
      
      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:admin_client).twice.and_return(mock_admin_client)
        expect(mock_discourse).to receive(:options).once.and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end
      
      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(4).times.and_return(mock_discourse)
        mock_schedule
      end

      it "do_live_updates runs" do
        expect(watch_group).to respond_to(:run)
        watch_group.run(mock_man, group_committed)
      end
    end


    context '.run sees already watching issue user' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(4).times.and_return(user_details_group_watching)
        mock_man
      end

      discourse_options_issue_user = discourse_options
      discourse_options_issue_user[:issue_users] = %w(Tony_Christopher)

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).once.and_return(discourse_options_issue_user)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).twice.and_return(mock_discourse)
        mock_schedule
      end
      
      it 'sees issue user' do
        expect { watch_group.run(mock_man, group_committed) }
            .to output(/Tony_Christopher already Watching/).to_stdout
      end
    end

  end

end

