require_relative '../../spec_helper'

describe MomentumApi::ActivityGroup do

  let(:user_details_active_user) { json_fixture("user_details_active_user.json") }
  let(:user_details_average_user_needs_update) { json_fixture("user_details_average_user_needs_update.json") }
  let(:user_details_average_user_updated) { json_fixture("user_details_average_user_updated.json") }
  let(:user_details_email_user) { json_fixture("user_details_email_user.json") }
  let(:user_details_inactive_user) { json_fixture("user_details_inactive_user.json") }

  user_preference_tasks = schedule_options[:user][:activity_groupping]

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
    expect(mock_man).to receive(:user_details).exactly(7).times.and_return(user_details_active_user)
    mock_man
  end

  describe '.activity_groupping' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      mock_dependencies
    end

    let(:activity_groupping) { MomentumApi::ActivityGroup.new(mock_schedule, user_preference_tasks, mock: mock_dependencies) }

    context "init" do

      it ".activity_groupping inits and responds" do
        expect(activity_groupping).to respond_to(:run)
        activity_groupping.run(mock_man)
      end
    end


    context "user already in correct activity group" do

      it "user leaves User Group Updated" do
        expect(activity_groupping).to respond_to(:run)
        activity_groupping.run(mock_man)
        expect(activity_groupping.instance_variable_get(:@counters)[:'User Group Updated']).to eql(0)
      end
    end


    context "finds average_user user that needs to be updated and removed from old group" do

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
        expect(mock_man).to receive(:user_details).exactly(9).times.and_return(user_details_average_user_needs_update)
        mock_man
      end

      activity_group_do_task_update = schedule_options[:user][:activity_groupping]
      activity_group_do_task_update[:average_user][:do_task_update] = true

      let(:activity_groupping) { MomentumApi::ActivityGroup.new(mock_schedule, activity_group_do_task_update, mock: mock_dependencies) }

      it "user Preference Targets updates" do
        expect(activity_groupping).to respond_to(:run)
                activity_groupping.run(mock_man)
        expect(activity_groupping.instance_variable_get(:@counters)[:'Average User Count']).to eql(1)
      end
    end


    context "finds active_user user" do

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
        expect(mock_man).to receive(:user_details).exactly(7).times.and_return(user_details_active_user)
        mock_man
      end

      activity_group_do_task_update = schedule_options[:user][:activity_groupping]
      activity_group_do_task_update[:active_user][:do_task_update] = true

      let(:activity_groupping) { MomentumApi::ActivityGroup.new(mock_schedule, activity_group_do_task_update, mock: mock_dependencies) }

      it "user Preference Targets updates" do
        expect(activity_groupping).to respond_to(:run)
                activity_groupping.run(mock_man)
        expect(activity_groupping.instance_variable_get(:@counters)[:'Active User Count']).to eql(1)
      end
    end


    context "finds email_user user" do

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
        expect(mock_man).to receive(:user_details).exactly(9).times.and_return(user_details_email_user)
        mock_man
      end

      activity_group_do_task_update = schedule_options[:user][:activity_groupping]
      activity_group_do_task_update[:email_user][:do_task_update] = true

      let(:activity_groupping) { MomentumApi::ActivityGroup.new(mock_schedule, activity_group_do_task_update, mock: mock_dependencies) }

      it "user Preference Targets updates" do
        expect(activity_groupping).to respond_to(:run)
                activity_groupping.run(mock_man)
        expect(activity_groupping.instance_variable_get(:@counters)[:'Email User Count']).to eql(1)
      end
    end


    context "finds inactive_user user" do

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
        expect(mock_man).to receive(:user_details).exactly(11).times.and_return(user_details_inactive_user)
        mock_man
      end

      activity_group_do_task_update = schedule_options[:user][:activity_groupping]
      activity_group_do_task_update[:inactive_user][:do_task_update] = true

      let(:activity_groupping) { MomentumApi::ActivityGroup.new(mock_schedule, activity_group_do_task_update, mock: mock_dependencies) }

      it "user Preference Targets updates" do
        expect(activity_groupping).to respond_to(:run)
                activity_groupping.run(mock_man)
        expect(activity_groupping.instance_variable_get(:@counters)[:'Inactive User Count']).to eql(1)
      end
    end


    context "do_live_updates, but do_task_update FALSE" do

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        mock_admin_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(9).times.and_return(user_details_average_user_needs_update)
        # expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(2).times.and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return(mock_discourse)
        mock_schedule
      end

      it "do not do_live_updates ActivityGroup because no do_task_update" do
        expect(activity_groupping).to respond_to(:run)
        activity_groupping.run(mock_man)
      end
    end


    context "do_live_updates and do_task_update for average_user" do

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:user).once.and_return user_details_average_user_updated
        expect(mock_admin_client).to receive(:group_remove).once.and_return({ "success": "OK","usernames": ["active_user"]})
        expect(mock_admin_client).to receive(:group_add).once.and_return({ "success": "OK","usernames": ["average_user"]})
        mock_admin_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:discourse).exactly(3).times.and_return(mock_discourse)
        expect(mock_man).to receive(:user_details).exactly(11).times.and_return(user_details_average_user_needs_update)
        expect(mock_man).to receive(:user_details).exactly(2).times.and_return(user_details_average_user_updated)
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      activity_group_do_task_update = schedule_options[:user][:activity_groupping]
      activity_group_do_task_update[:average_user][:do_task_update] = true
      # activity_group_do_task_update[:user_fields][:user_fields][:do_task_update] = true

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:admin_client).exactly(3).times.and_return(mock_admin_client)
        expect(mock_discourse).to receive(:options).exactly(5).times.and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(6).times.and_return(mock_discourse)
        mock_schedule
      end

      let(:activity_groupping) { MomentumApi::ActivityGroup.new(mock_schedule, activity_group_do_task_update, mock: mock_dependencies) }

      it "do_live_updates & do_task_update = activity_groupping" do
        expect(activity_groupping).to respond_to(:run)
        activity_groupping.run(mock_man)
      end
    end


    context '.activity_groupping sees issue user' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(10).times.and_return(user_details_average_user_needs_update)
        # expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      discourse_options_issue_user = discourse_options
      discourse_options_issue_user[:issue_users] = %w(average_user)

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(2).times.and_return(discourse_options_issue_user)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(3).times.and_return(mock_discourse)
        mock_schedule
      end

      it 'sees issue user' do
        expect { activity_groupping.run(mock_man) }
            .to output(/average_user in ActivityGroup/).to_stdout
      end
    end

  end
end

