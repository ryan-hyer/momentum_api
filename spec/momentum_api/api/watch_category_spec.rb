require_relative '../../spec_helper'

describe MomentumApi::WatchCategory do

  let(:user_details) { json_fixture("user_details.json") }
  let(:category_committed_not_watching) { json_fixture("category_committed_not_watching.json") }
  let(:categories) { json_fixture("categories.json") }
  let(:category_committed_watching) { json_fixture("category_committed_watching.json") }

  options = schedule_options[:category]

  let(:mock_discourse) do
    mock_discourse = instance_double('discourse')
    expect(mock_discourse).to receive(:options).exactly(3).times.and_return(discourse_options)
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
    expect(mock_man).to receive(:user_details).once.times.and_return(user_details)
    expect(mock_man).to receive(:discourse).exactly(2).times.and_return(mock_discourse)
    mock_man
  end

  describe '.run' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      mock_dependencies
    end

    let(:watch_category) { MomentumApi::WatchCategory.new(mock_schedule, options, mock: mock_dependencies) }

    context "init" do
      
      it ".run inits and responds" do
        expect(watch_category).to respond_to(:run)
        watch_category.run(mock_man, 'category', options[:matching_team], group_name: 'group_name')
      end
    end


    context "group matching category" do

      it "Category Update Targets updates" do
        expect(watch_category).to respond_to(:run)
        watch_category.run(mock_man, category_committed_not_watching, options[:matching_team], group_name: 'category_committed')
        expect(watch_category.instance_variable_get(:@counters)[:'Category Update Targets']).to eql(1)
      end
    end

    
    context "do_live_updates" do

      let(:mock_user_client) do
        mock_user_client = instance_double('user_client')
        expect(mock_user_client).to receive(:categories).once.and_return categories
        expect(mock_user_client).to receive(:category_set_user_notification).once
        mock_user_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).once.and_return(user_details)
        expect(mock_man).to receive(:user_client).twice.and_return(mock_user_client)
        expect(mock_man).to receive(:discourse).exactly(4).times.and_return(mock_discourse)
        mock_man
      end
      
      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(5).times.and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end
      
      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).twice.and_return(mock_discourse)
        mock_schedule
      end

      it "do_live_updates runs" do
        expect(watch_category).to respond_to(:run)
        watch_category.run(mock_man, category_committed_not_watching, options[:matching_team], group_name: 'category_committed')
      end
    end


    context '.run sees already watching issue user' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).twice.and_return(user_details)
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
        expect { watch_category.run(mock_man, category_committed_watching,
                                     options[:matching_team], group_name: 'category_committed_watching') }
            .to output(/Tony_Christopher already Watching/).to_stdout
      end
    end

  end

end

