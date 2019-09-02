require_relative '../../spec_helper'

describe MomentumApi::Ownership do

  let(:user_details_preference_correct) { json_fixture("user_details.json") }
  let(:user_details_preference_wrong) { json_fixture("user_details_preference_wrong.json") }
  let(:user_admin_user_sso) { json_fixture("user_admin_user_sso.json") }

  user_preference_tasks = schedule_options[:user][:preferences]

  let(:mock_discourse) do
    mock_discourse = instance_double('discourse')
    # expect(mock_discourse).to receive(:options).once.and_return(discourse_options)
    expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
    mock_discourse
  end

  let(:mock_schedule) do
    mock_schedule = instance_double('schedule')
    expect(mock_schedule).to receive(:discourse).exactly(1).times.and_return(mock_discourse)
    mock_schedule
  end

  let(:mock_man) do
    mock_man = instance_double('man')
    expect(mock_man).to receive(:user_details).exactly(4).times.and_return(user_details_preference_correct)
    mock_man
  end

  describe '.preference' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      mock_dependencies
    end

    let(:ownership) { MomentumApi::Ownership.new(mock_schedule, user_preference_tasks, mock: mock_dependencies) }

    context "init" do

      it ".run inits and responds" do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
      end

    end


    context "user already at correct preference setting" do

      # it "user leaves Update Preference Targets" do
      #   expect(ownership).to respond_to(:run)
      #   ownership.run(mock_man)
      #   expect(ownership.instance_variable_get(:@counters)[:'User Preference Targets']).to eql(0)
      # end
    end


    context "user needs to be updated" do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(4).times.and_return(discourse_options)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(5).times.and_return(mock_discourse)
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(8).times.and_return(user_details_preference_wrong)
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end
      
      # it "user Preference Targets updates" do
      #   expect(ownership).to respond_to(:run)
      #           ownership.run(mock_man)
      #   expect(ownership.instance_variable_get(:@counters)[:'User Preference Targets']).to eql(2)
      # end
    end


    context "do_live_updates" do

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        mock_admin_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(8).times.and_return(user_details_preference_wrong)
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(4).times.and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(5).times.and_return(mock_discourse)
        mock_schedule
      end

      # it "do not do_live_updates preferences because no do_task_update" do
      #   expect(ownership).to respond_to(:run)
      #   ownership.run(mock_man)
      # end
    end


    context "do_live_updates and do_task_update for user_option" do

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:user).twice.and_return user_details_preference_correct
        expect(mock_admin_client).to receive(:update_user).twice.and_return({"body": {"success": "OK"}})
        mock_admin_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:discourse).exactly(2).times.and_return(mock_discourse)
        expect(mock_man).to receive(:user_details).exactly(12).times.and_return(user_details_preference_wrong)
        expect(mock_man).to receive(:print_user_options).exactly(4).times
        mock_man
      end

      user_pref_tasks_do_task_update = schedule_options[:user][:preferences]
      user_pref_tasks_do_task_update[:user_option][:email_messages_level][:do_task_update] = true
      user_pref_tasks_do_task_update[:user_fields][:user_fields][:do_task_update] = true

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:admin_client).exactly(4).times.and_return(mock_admin_client)
        expect(mock_discourse).to receive(:options).exactly(6).times.and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(9).times.and_return(mock_discourse)
        mock_schedule
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, user_pref_tasks_do_task_update, mock: mock_dependencies) }

      # it "do_live_updates & do_task_update = preferences" do
      #   expect(ownership).to respond_to(:run)
      #   ownership.run(mock_man)
      # end
      
    end


    context "do_live_updates and do_task_update for user_option" do

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:user).twice.and_return user_details_preference_correct
        expect(mock_admin_client).to receive(:user_sso).once.and_return user_admin_user_sso
        expect(mock_admin_client).to receive(:update_user).twice.and_return({"body": {"success": "OK"}})
        mock_admin_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:discourse).exactly(2).times.and_return(mock_discourse)
        expect(mock_man).to receive(:user_details).exactly(13).times.and_return(user_details_preference_wrong)
        expect(mock_man).to receive(:print_user_options).exactly(4).times
        mock_man
      end
      
      user_pref_tasks_do_task_update = schedule_options[:user][:preferences]
      user_pref_tasks_do_task_update[:user_option][:email_messages_level][:do_task_update] = true
      user_pref_tasks_do_task_update[:user_fields][:user_fields][:do_task_update] = true

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:admin_client).exactly(5).times.and_return(mock_admin_client)
        expect(mock_discourse).to receive(:options).exactly(6).times.and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(10).times.and_return(mock_discourse)
        mock_schedule
      end


      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, user_pref_tasks_do_task_update, mock: mock_dependencies) }
      
      describe '.find_set_level' do

        memberful_test_export = csv_fixture("memberful_test_export.csv")
        user_pref_tasks_do_task_update[:user_fields][:user_fields][:set_level] = {'6': memberful_test_export}

        # it "find lookup value to update" do
        #   expect(ownership).to respond_to(:run)
        #   ownership.run(mock_man)
        # end

      end

    end


    context '.preferences sees issue user' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(10).times.and_return(user_details_preference_wrong)
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      discourse_options_issue_user = discourse_options
      discourse_options_issue_user[:issue_users] = %w(Tony_Christopher)

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(4).times.and_return(discourse_options_issue_user)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(5).times.and_return(mock_discourse)
        mock_schedule
      end

      # it 'sees issue user' do
      #   expect { ownership.run(mock_man) }
      #       .to output(/Tony_Christopher in Ownership/).to_stdout
      # end
    end

  end
end

