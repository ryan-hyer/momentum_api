require_relative '../../spec_helper'

describe MomentumApi::Notifications do

  let(:user_details) { json_fixture("user_details.json") }

  options = schedule_options[:watching]
  # options[:update_type] = 'not_voted'

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
    expect(mock_man).to receive(:user_details).once.times.and_return(user_details)
    mock_man
  end

  describe '.set_category_notification' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      mock_dependencies
    end

    let(:notification) { MomentumApi::Notifications.new(mock_schedule, options: options) }

    describe "init message master" do

      it ".set_category_notification inits and responds" do
        expect(notification).to respond_to(:set_category_notification)
        notification.set_category_notification(mock_man, 'category', 'group_name', options.first(1).to_h)
      end
    end
  end

end

