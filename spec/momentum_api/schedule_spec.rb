require_relative '../spec_helper'

describe MomentumApi::Schedule do

  let(:user_details) { json_fixture("user_details.json") }
  let(:group_owner) { json_fixture("group_owner.json") }
  let(:group_committed) { json_fixture("group_committed.json") }
  let(:category_list) { json_fixture("categories.json") }
  
  let(:mock_discourse) do
    mock_discourse = instance_double('mock_discourse')
    # expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
    expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
    mock_discourse
  end

  context 'a non matching group' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:run).once
      mock_dependencies
    end

    describe '.group_cases should respond, but do nothing with fake group' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).once.and_return(user_details)
        mock_man
      end

      let(:schedule) { MomentumApi::Schedule.new(mock_discourse, schedule_options, mock: mock_dependencies) }

      it 'responds to group_cases' do
        schedule.group_cases(mock_man, 'fake group')
        expect(schedule).to respond_to(:group_cases)
      end
    end
  end


  context 'a matching group' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:run).twice
      mock_dependencies
    end


    describe '.group_cases sees issue user' do

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:run).exactly(3).times
        mock_dependencies
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('mock_discourse')
        reset_options = discourse_options
        reset_options[:issue_users] = %w(Tony_Christopher)
         expect(mock_discourse).to receive(:options).exactly(1).times.and_return(reset_options)
        mock_discourse
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(2).times.and_return(user_details)
        expect(mock_man).to receive(:is_owner=).once.and_return(true)
        mock_man
      end

      let(:schedule) { MomentumApi::Schedule.new(mock_discourse, schedule_options, mock: mock_dependencies) }

      it 'responds to scan_contexts and prints issue user' do
        expect { schedule.group_cases(mock_man, group_owner) }
            .to output(/Tony_Christopher in group_cases/).to_stdout
      end
    end
  end


  describe '.category cases' do

    let(:users_categories) {json_fixture("categories.json")}

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:counters).twice.and_return({'Category Notify Updated': 0})
      expect(mock_dependencies).to receive(:counters).twice.and_return({'Category Notify Updated': 1})
      expect(mock_dependencies).to receive(:run).once
      mock_dependencies
    end

    let(:mock_discourse) do
      mock_discourse = instance_double('mock_discourse')
      expect(mock_discourse).to receive(:options).exactly(13).times.and_return(discourse_options)
      mock_discourse
    end


    context 'group matching_team' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(14).times.and_return(user_details)
        expect(mock_man).to receive(:users_categories).once.and_return(users_categories)
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:run).once.with(mock_man, anything, 'Committed', anything)
        mock_dependencies
      end

      let(:schedule) { MomentumApi::Schedule.new(mock_discourse, schedule_options, mock: mock_dependencies) }

      it '.category_cases should find group that macthes category' do
        schedule.category_cases(mock_man, group_committed)
        expect(schedule).to respond_to(:category_cases)
      end
    end
    

    context 'watch Essential, Growth, and Meta' do

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:run).exactly(3).times
        mock_dependencies
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(16).times.and_return(user_details)
        expect(mock_man).to receive(:users_categories).once.and_return(users_categories)
        mock_man
      end

      let(:schedule) { MomentumApi::Schedule.new(mock_discourse, schedule_options, mock: mock_dependencies) }

      it '.category_cases should find owner not watching Essential' do
        schedule.category_cases(mock_man, group_owner)
        expect(schedule).to respond_to(:category_cases)
      end
    end


    context '.group_cases sees issue user' do

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:run).exactly(3).times
        mock_dependencies
      end
      let(:mock_discourse) do
        mock_discourse = instance_double('mock_discourse')
        reset_options = discourse_options
        reset_options[:issue_users] = %w(Tony_Christopher)
         expect(mock_discourse).to receive(:options).exactly(13).times.and_return(reset_options)
        mock_discourse
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(29).times.and_return(user_details)
        expect(mock_man).to receive(:users_categories).once.and_return(users_categories)
        mock_man
      end

      let(:schedule) { MomentumApi::Schedule.new(mock_discourse, schedule_options, mock: mock_dependencies) }

      it 'responds to scan_contexts and prints issue user' do
        expect { schedule.category_cases(mock_man, group_owner) }
            .to output(/Tony_Christopher Category case on category/).to_stdout
      end
    end
  end


  describe '.user_cases' do
    
    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:run).exactly(3).times
      mock_dependencies
    end

    let(:mock_discourse) do
      mock_discourse = instance_double('mock_discourse')
      mock_discourse
    end

    let(:mock_man) do
      mock_man = instance_double('man')
      mock_man
    end

    let(:schedule) { MomentumApi::Schedule.new(mock_discourse, schedule_options, mock: mock_dependencies) }

    it '.category_cases should find group that macthes category' do
      schedule.user_cases(mock_man)
      expect(schedule).to respond_to(:user_cases)
    end

  end
end

