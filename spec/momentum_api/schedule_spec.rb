require_relative '../spec_helper'

describe MomentumApi::Schedule do

  let(:user_details) { json_fixture("user_details.json") }
  let(:category_list) { json_fixture("categories.json") }

  let(:mock_dependencies) do
    mock_dependencies = instance_double('mock_dependencies')
    mock_dependencies
  end

  let(:mock_discourse) do
    mock_discourse = instance_double('mock_discourse')
    expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
    expect(mock_discourse).to receive(:issue_users).once.and_return([])
    mock_discourse
  end
  
  describe '.group_cases should respond' do

    subject { MomentumApi::Schedule.new(mock_discourse, schedule_options, mock_dependencies) }

    it 'responds to group_cases' do
      subject.group_cases(user_details, 'fake group')
      expect(subject).to respond_to(:group_cases)
    end
  end


  describe '.group_cases should call .trust_level_updates for Owners' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:run_scans).once
      mock_dependencies
    end
    
    let(:schedule) { MomentumApi::Schedule.new(mock_discourse, schedule_options, mock_dependencies) }

    before do
      # allow(schedule).to receive(:update_user_trust_level)
      # allow_any_instance_of(MomentumApi::Schedule).to receive(:update_user_trust_level)
    end

    it 'responds to group_cases' do
      allow(schedule).to receive(:update_user_trust_level)
      schedule.group_cases(user_details, 'Owner')
      expect(schedule).to respond_to(:update_user_trust_level)
    end
  end
end

