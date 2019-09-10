require_relative '../../spec_helper'

describe MomentumApi::Ownership do

  let(:membership_subscription_2020_08_25) { json_fixture("membership_subscription_2020_08_25.json") }
  let(:user_details_ownership_blank) { json_fixture("user_details_ownership_blank.json") }

  let(:user_details_ownership_2020_08_25_CA_R0) { json_fixture("user_details_ownership_2020_08_25_CA_R0.json") }
  let(:user_details_ownership_2020_08_25_CA_R1) { json_fixture("user_details_ownership_2020_08_25_CA_R1.json") }

  let(:user_details_ownership_2020_01_02_MM) { json_fixture("user_details_ownership_2020_01_02_MM.json") }
  let(:user_details_ownership_2020_01_02_MM_R0) { json_fixture("user_details_ownership_2020_01_02_MM_R0.json") }
  let(:user_details_ownership_2020_01_02_MM_R1) { json_fixture("user_details_ownership_2020_01_02_MM_R1.json") }
  let(:user_details_ownership_renews_value_invalid) { json_fixture("user_details_ownership_renews_value_invalid.json") }

  ownership_tasks = schedule_options[:ownership]

  let(:mock_user_client) do
    mock_user_client = instance_double('user_client')
    expect(mock_user_client).to receive(:membership_subscriptions).once.and_return []
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
    expect(mock_schedule).to receive(:discourse).exactly(2).times.and_return(mock_discourse)
    mock_schedule
  end

  let(:mock_man) do
    mock_man = instance_double('man')
    expect(mock_man).to receive(:user_details).exactly(10).times.and_return(user_details_ownership_2020_01_02_MM_R0)
    expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
    mock_man
  end

  let(:mock_dependencies) do
    mock_dependencies = instance_double('mock_dependencies')
    mock_dependencies
  end

  describe '.run' do

    let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_tasks, mock: mock_dependencies) }


    context '2 Ownership actions against a valid, non-expiring user renews_value' do

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(4).times.and_return(Date.new(2019,12,3))
        mock_dependencies
      end

      it "inits and finds 2 Ownership actions and a valid user renews_value" do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(0)
      end

    end
    

    context 'invalid user renews_value' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(10).times.and_return(user_details_ownership_renews_value_invalid)
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        mock_man
      end

      it "inits and finds 2 Ownership actions and a valid renews_value" do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(0)
      end

    end


    context 'Card Auto Renewing user expiring next week, update off' do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).twice.and_return(discourse_options)
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
        expect(mock_man).to receive(:user_details).exactly(11).times.and_return(user_details_ownership_2020_08_25_CA_R0)
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(4).times.and_return(Date.new(2020,8,20))
        mock_dependencies
      end

      it 'sends PM asking user to renew and sets user to R1' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
      end

    end

    
    context 'Memberful Manual user expiring next week, update off' do

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).twice.and_return(discourse_options)
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
        expect(mock_man).to receive(:user_details).exactly(11).times.and_return(user_details_ownership_2020_01_02_MM_R0)
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(4).times.and_return(Date.new(2019,12,26))
        mock_dependencies
      end

      it 'sends PM asking user to renew and sets user to R1' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
      end

    end


    context 'Memberful expires next week, do_live_updates' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true
      
      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).twice.and_return(options_do_live_updates)
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
        expect(mock_man).to receive(:user_details).exactly(11).times.and_return(user_details_ownership_2020_01_02_MM_R0)
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(1).times
        mock_man
      end

      
      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(4).times.and_return(Date.new(2019,12,26))
        mock_dependencies
      end

      it 'finds user expiring in 1 week' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
      end

    end

    
    context 'Card Auto Renewing user expires next week, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:auto][:card_auto_renew_expires_next_week][:do_task_update] = true

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:user).once.and_return user_details_ownership_2020_08_25_CA_R1
        expect(mock_admin_client).to receive(:update_user).once
                                         .with("Tony_Christopher", {user_fields: {'6': '2020-08-25 CA R1'}})
                                         .and_return({"body": {"success": "OK"}})
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(3).and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        expect(mock_discourse).to receive(:admin_client).exactly(2).times.and_return(mock_admin_client)
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(6).times.and_return(mock_discourse)
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(13).times.and_return(user_details_ownership_2020_08_25_CA_R0)
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(4).times.and_return(Date.new(2020,8,20))
        expect(mock_dependencies).to receive(:send_private_message)
                                         .with(mock_man, /Just a friendly reminder/, /Thank You for Owning Momentum!/,
                                               from_username: 'Kim_Miller', to_username: nil)
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'sends PM asking user to renew and sets user to R1' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(1)
      end

    end

    
    context 'Memberful expires next week, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:manual][:memberful_expires_next_week][:do_task_update] = true

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:user).once.and_return user_details_ownership_2020_01_02_MM_R1
        expect(mock_admin_client).to receive(:update_user).once
                                         .with("Tony_Christopher", {user_fields: {"6": "2020-01-02 MM R1"}})
                                         .and_return({"body": {"success": "OK"}})
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(3).and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        expect(mock_discourse).to receive(:admin_client).exactly(2).times.and_return(mock_admin_client)
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(6).times.and_return(mock_discourse)
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(13).times.and_return(user_details_ownership_2020_01_02_MM_R0)
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(4).times.and_return(Date.new(2019,12,26))
        expect(mock_dependencies).to receive(:send_private_message)
                                         .with(mock_man, /Momentum has a new membership system/, /Thank You for Owning Momentum!/,
                                               from_username: 'Kim_Miller', to_username: nil)
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'sends PM asking user to renew and sets user to R1' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(1)
      end

    end


    context 'Card Auto ownership new, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:auto][:card_auto_renew_expires_next_week][:do_task_update] = true

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:user).once.and_return user_details_ownership_blank
        expect(mock_admin_client).to receive(:update_user).once
                                         .with("Tony_Christopher", {user_fields: {"6": "2020-08-25 CA R0"}})
                                         .and_return({"body": {"success": "OK"}})
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(3).and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return []
        expect(mock_discourse).to receive(:admin_client).exactly(2).times.and_return(mock_admin_client)
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(6).times.and_return(mock_discourse)
        mock_schedule
      end

      let(:mock_user_client) do
        mock_user_client = instance_double('user_client')
        expect(mock_user_client).to receive(:membership_subscriptions).exactly(1).times.and_return membership_subscription_2020_08_25
        mock_user_client
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(15).times.and_return user_details_ownership_blank
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        # expect(mock_dependencies).to receive(:today).exactly(6).times.and_return(Date.new(2019,01,03))
        expect(mock_dependencies).to receive(:send_private_message)
                                         .with(mock_man, /Momentum has a new member.../,
                                               /Momentum Has a new Annually Subscribing Owner/,
                                               from_username: 'Kim_Miller', to_username: 'Kim_Miller')
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'sends new Owner admin PM and sets user to R0' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(1)
      end

    end

    
    context 'manual ownership new, do_live_updates and do_task_update' do

      options_do_live_updates = discourse_options
      options_do_live_updates[:do_live_updates] = true

      ownership_do_task_update = schedule_options[:ownership]
      ownership_do_task_update[:manual][:memberful_expires_next_week][:do_task_update] = true

      let(:mock_admin_client) do
        mock_admin_client = instance_double('admin_client')
        expect(mock_admin_client).to receive(:user).once.and_return user_details_ownership_2020_01_02_MM
        expect(mock_admin_client).to receive(:update_user).once
                                         .with("Tony_Christopher", {user_fields: {"6": "2020-01-02 MM R0"}})
                                         .and_return({"body": {"success": "OK"}})
        mock_admin_client
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(3).and_return(options_do_live_updates)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        expect(mock_discourse).to receive(:admin_client).exactly(2).times.and_return(mock_admin_client)
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(6).times.and_return(mock_discourse)
        mock_schedule
      end

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(15).times.and_return(user_details_ownership_2020_01_02_MM)
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        expect(mock_man).to receive(:print_user_options).exactly(2).times
        mock_man
      end

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:today).exactly(4).times.and_return(Date.new(2019,01,03))
        expect(mock_dependencies).to receive(:send_private_message)
                                         .with(mock_man, /Momentum has a new member.../,
                                               /Momentum Has a new Manually Entered Owner/,
                                               from_username: 'Kim_Miller', to_username: 'Kim_Miller')
        mock_dependencies
      end

      let(:ownership) { MomentumApi::Ownership.new(mock_schedule, ownership_do_task_update, mock: mock_dependencies) }

      it 'sends new Owner admin PM and sets user to R0' do
        expect(ownership).to respond_to(:run)
        ownership.run(mock_man)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Targets']).to eql(1)
        expect(ownership.instance_variable_get(:@counters)[:'Ownership Updated']).to eql(1)
      end

    end


    context '.ownership sees issue user' do

      let(:mock_man) do
        mock_man = instance_double('man')
        expect(mock_man).to receive(:user_details).exactly(11).times.and_return(user_details_ownership_renews_value_invalid)
        expect(mock_man).to receive(:user_client).exactly(1).times.and_return mock_user_client
        mock_man
      end

      discourse_options_issue_user = discourse_options
      discourse_options_issue_user[:issue_users] = %w(Tony_Christopher)

      let(:mock_discourse) do
        mock_discourse = instance_double('discourse')
        expect(mock_discourse).to receive(:options).exactly(1).times.and_return(discourse_options_issue_user)
        expect(mock_discourse).to receive(:scan_pass_counters).once.and_return([])
        mock_discourse
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('schedule')
        expect(mock_schedule).to receive(:discourse).exactly(2).times.and_return(mock_discourse)
        mock_schedule
      end

      it 'sees issue user' do
        expect { ownership.run(mock_man) }
            .to output(/Tony_Christopher in Ownership/).to_stdout
      end
    end

  end
end

