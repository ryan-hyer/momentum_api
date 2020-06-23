require_relative '../spec_helper'

describe MomentumApi::Discourse do
  
  let(:group_member_list) { json_fixture("groups_members.json")[0..1]}
  let(:user_details) { json_fixture("user_details.json") }
  let(:category_list) { json_fixture("categories.json") }

  
  context 'regular group of users' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:group_members).and_return(group_member_list)
      expect(mock_dependencies).to receive(:user).and_return(user_details).exactly(group_member_list.length).times
      expect(mock_dependencies).to receive(:run).exactly(group_member_list.length).times
      mock_dependencies
    end

    describe '.apply_to_users all' do

      subject {MomentumApi::Discourse.new(discourse_options, schedule_options: schedule_options, mock: mock_dependencies)}

      it 'responds to apply_to_users and runs thru default group of users' do
        subject.apply_to_users
        expect(subject).to respond_to(:apply_to_users)
        expect(subject.instance_variable_get(:@counters)[:'Processed Users']).to eql(group_member_list.length)
      end
    end

    describe '.apply_to_users in group' do

      subject {MomentumApi::Discourse.new(discourse_options, schedule_options: schedule_options, mock: mock_dependencies)}

      it 'responds to apply_to_users and runs thru group of users' do
        subject.apply_to_users
        expect(subject).to respond_to(:apply_to_users)
        expect(subject.instance_variable_get(:@counters)[:'Processed Users']).to eql(group_member_list.length)
      end
    end
    
    describe '.apply_to_users in group to see issue user' do

      subject {MomentumApi::Discourse.new(discourse_options, schedule_options: schedule_options, mock: mock_dependencies)}

      it 'responds to apply_to_users and runs thru group of users' do
        reset_options = subject.instance_variable_get(:@options)
        reset_options[:issue_users] = %w(Tony_Christopher)
        subject.instance_variable_set(:@options, reset_options)
        expect {subject.apply_to_users}
            .to output(/Tony_Christopher in apply_to_group_users method/).to_stdout
      end
    end

  end


  context 'a single user' do

    describe '.apply_to_users single user' do

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:group_members).and_return(group_member_list)
        expect(mock_dependencies).to receive(:user).and_return(user_details).once
        expect(mock_dependencies).to receive(:run).once
        mock_dependencies
      end

      discourse_single_user_option = discourse_options
      discourse_single_user_option[:target_username] = 'Tony_Christopher'
      subject { MomentumApi::Discourse.new(discourse_single_user_option, schedule_options: schedule_options, mock: mock_dependencies) }

      it 'runs single user and responds to apply_to_users' do
        subject.apply_to_users
        expect(subject).to respond_to(:apply_to_users)
        expect(subject.instance_variable_get(:@counters)[:'Processed Users']).to eql(1)
      end
    end
  end


  context 'staged users' do

    describe '.apply_to_users skips staged user' do

      let(:group_member_list) { json_fixture("groups_members.json")}
      let(:staged_user_details) { json_fixture("user_staged.json") }

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:group_members).and_return(group_member_list)
        expect(mock_dependencies).to receive(:user).and_return(staged_user_details).once
        mock_dependencies
      end

      discourse_staged_user_option = discourse_options
      discourse_staged_user_option[:target_username] = 'Noah_Salzman'
      subject { MomentumApi::Discourse.new(discourse_staged_user_option, schedule_options: schedule_options, mock: mock_dependencies) }

      it 'skips staged users and responds to apply_to_users' do
        subject.apply_to_users
        expect(subject).to respond_to(:apply_to_users)
        expect(subject.instance_variable_get(:@counters)[:'Skipped Users']).to eql(1)
      end
    end
  end


  context 'no group specified' do

    describe '.apply_to_users uses default group' do

      let(:group_member_list) { json_fixture("groups_members.json")}

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:group_members).and_return(group_member_list)
        expect(mock_dependencies).to receive(:user).and_return(user_details).exactly(group_member_list.length).times
        expect(mock_dependencies).to receive(:run).exactly(group_member_list.length).times
        mock_dependencies
      end

      discourse_no_group_specified = discourse_options
      discourse_no_group_specified[:target_groups] = []
      subject { MomentumApi::Discourse.new(discourse_no_group_specified, schedule_options: schedule_options, mock: mock_dependencies) }

      it 'responds to apply_to_users and uses trust_level_1 default group' do
        subject.apply_to_users
        expect(subject).to respond_to(:apply_to_users)
        expect(subject.instance_variable_get(:@counters)[:'Processed Users']).to eql(group_member_list.length)
      end
    end
  end

  
  context 'errors are raised' do

    describe "client.group_members may raise DiscourseApi::TooManyRequests error" do

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:group_members).and_raise('DiscourseApi::TooManyRequests')
        mock_dependencies
      end

      subject { MomentumApi::Discourse.new(discourse_options, schedule_options: schedule_options, mock: mock_dependencies) }

      it "responds to unknown .connect_to_instance" do
        expect { subject.apply_to_users }
            .to raise_error('DiscourseApi::TooManyRequests')
      end
    end

    describe "client.user  DiscourseApi::TooManyRequests x2 raises error" do

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:group_members).and_return(group_member_list).once
        expect(mock_dependencies).to receive(:user).exactly(2).times
                                         .and_raise(DiscourseApi::TooManyRequests.new('error message here'))
        mock_dependencies
      end

      subject { MomentumApi::Discourse.new(discourse_options, schedule_options: schedule_options, mock: mock_dependencies) }

      it ". apply_to_users TooManyRequests x2 raises error" do
        expect { subject.apply_to_users }
            .to raise_error(DiscourseApi::TooManyRequests)
        expect(subject.instance_variable_get(:@counters)[:'Processed Users']).to eql(0)
      end
    end
  end

  
 context 'final scan summary' do
    
    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      mock_dependencies
    end
    
    describe ".connect_to_instance" do

      subject { MomentumApi::Discourse.new(discourse_options, schedule_options: schedule_options, mock: mock_dependencies) }

      it "responds to live .connect_to_instance" do
        subject.connect_to_instance('KM_Admin', 'https://discourse.gomomentum.org')
        expect(subject).to respond_to(:connect_to_instance)
      end

      it "responds to staging .connect_to_instance" do
        subject.connect_to_instance('KM_Admin', 'https://staging.gomomentum.org')
        expect(subject).to respond_to(:connect_to_instance)
      end

      it "responds to local .connect_to_instance" do
        subject.connect_to_instance('KM_Admin', 'local')
        expect(subject).to respond_to(:connect_to_instance)
      end

      it "responds to unknown .connect_to_instance" do
        expect { subject.connect_to_instance('KM_Admin', 'some_unknown') }
            .to raise_error('Host unknown error has occured')
      end
    end

    describe ".scan_summary should tally counter totals" do

      subject { MomentumApi::Discourse.new(discourse_options, schedule_options: schedule_options, mock: mock_dependencies) }

      it "responds to .scan_summary and find 0 init" do
        subject.scan_summary
        expect(subject).to respond_to(:scan_summary)
        expect(subject.instance_variable_get(:@counters)[:'Processed Users']).to eql(0)
      end

      it "responds to .scan_summary and print to stand out" do
        subject.scan_summary
        expect(subject).to respond_to(:scan_summary)
        expect { subject.scan_summary }.to output(/Discourse Men/).to_stdout
      end
    end
  end
end

