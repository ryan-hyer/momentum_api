require_relative '../spec_helper'

describe MomentumApi::Discourse do

  do_live_updates =   false

  scan_options = {
      team_category_watching:   true,
      essential_watching:       true,
      growth_first_post:        true,
      meta_first_post:          true,
      trust_level_updates:      true,
      score_user_levels: {
          update_type:  'not_voted',      # have_voted, not_voted, newly_voted, all
          target_post:  28707,            # 28649
          target_polls: %w(version_two),  # basic new version_two
          poll_url:     'https://discourse.gomomentum.org/t/user-persona-survey/6485/20'
      },
      user_group_alias_notify:  true
  }

  let(:group_member_list) { json_fixture("groups_members.json")[0..1]}
  let(:user_details) { json_fixture("user.json") }
  let(:category_list) { json_fixture("categories.json") }

  
  describe '.apply_to_users all' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:group_members).and_return(group_member_list)
      expect(mock_dependencies).to receive(:user).and_return(user_details).exactly(group_member_list.length).times
      expect(mock_dependencies).to receive(:categories).and_return(category_list).exactly(group_member_list.length).times
      expect(mock_dependencies).to receive(:run_scans).exactly(group_member_list.length).times
      mock_dependencies
    end

    subject { MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
                                         target_groups=nil, target_username=nil, mock: mock_dependencies) }

    it 'responds to apply_to_users and runs thru default group of users' do
      subject.apply_to_users(scan_options)
      expect(subject).to respond_to(:apply_to_users)
    end
  end

  
  describe '.apply_to_users in group' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:group_members).and_return(group_member_list)
      expect(mock_dependencies).to receive(:user).and_return(user_details).exactly(group_member_list.length).times
      expect(mock_dependencies).to receive(:categories).and_return(category_list).exactly(group_member_list.length).times
      expect(mock_dependencies).to receive(:run_scans).exactly(group_member_list.length).times
      mock_dependencies
    end

    subject { MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
                                         target_groups=%w(trust_level_1), target_username=nil, mock: mock_dependencies) }

    it 'responds to apply_to_users and runs thru group of users' do
      subject.apply_to_users(scan_options)
      expect(subject).to respond_to(:apply_to_users)
    end
  end


  describe '.apply_to_users single user' do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:group_members).and_return(group_member_list)
      expect(mock_dependencies).to receive(:user).and_return(user_details).once
      expect(mock_dependencies).to receive(:categories).and_return(category_list).once
      expect(mock_dependencies).to receive(:run_scans).once
      mock_dependencies
    end

    subject { MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
                                         target_groups=%w(trust_level_1), target_username='Tony_Christopher', mock: mock_dependencies) }

    it 'runs single user and responds to apply_to_users' do
      subject.apply_to_users(scan_options)
      expect(subject).to respond_to(:apply_to_users)
    end
  end


  describe '.apply_to_users skips staged user' do

    let(:group_member_list) { json_fixture("groups_members.json")}
    let(:staged_user_details) { json_fixture("user_staged.json") }

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:group_members).and_return(group_member_list)
      expect(mock_dependencies).to receive(:user).and_return(staged_user_details).once
      mock_dependencies
    end

    subject { MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
                                         target_groups=nil, target_username='Noah_Salzman', mock: mock_dependencies) }

    it 'skips staged users and responds to apply_to_users' do
      subject.apply_to_users(scan_options)
      expect(subject).to respond_to(:apply_to_users)
      expect(subject.instance_variable_get(:@skipped_users)).to eql(1)
    end
  end


  describe "client.group_members may raise DiscourseApi::TooManyRequests error" do
    
    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:group_members).and_raise('DiscourseApi::TooManyRequests')
      mock_dependencies
    end

    subject { MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
                                         target_groups=%w(trust_level_1), target_username=nil, mock: mock_dependencies) }

    it "responds to unknown .connect_to_instance" do
      expect { subject.apply_to_users(scan_options) }
          .to raise_error('DiscourseApi::TooManyRequests')
    end
  end


  describe "client.user may raise DiscourseApi::TooManyRequests error" do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:group_members).and_return(group_member_list).once
      expect(mock_dependencies).to receive(:user).exactly(2).times
                                       .and_raise(DiscourseApi::TooManyRequests.new('error message here'))
      mock_dependencies
    end

    subject { MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
                                         target_groups=%w(trust_level_1), target_username=nil, mock: mock_dependencies) }
    
    it "responds to unknown .connect_to_instance" do
      expect { subject.apply_to_users(scan_options) }
        .to raise_error(DiscourseApi::TooManyRequests)
    end
  end


  describe "client.categories may raise DiscourseApi::TooManyRequests" do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:group_members).and_return(group_member_list).once
      expect(mock_dependencies).to receive(:user).and_return(user_details).once
      expect(mock_dependencies).to receive(:categories).exactly(2).times
                                       .and_raise(DiscourseApi::TooManyRequests.new('error message here'))
      mock_dependencies
    end

    subject { MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
                                         target_groups=%w(trust_level_1), target_username=nil, mock: mock_dependencies) }

    it "responds to unknown .connect_to_instance" do
      expect { subject.apply_to_users(scan_options) }
        .to raise_error(DiscourseApi::TooManyRequests)
    end
  end


  describe "client.categories may raise DiscourseApi::UnauthenticatedError" do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:group_members).and_return(group_member_list).once
      expect(mock_dependencies).to receive(:user).and_return(user_details).exactly(group_member_list.length).times
      expect(mock_dependencies).to receive(:categories).exactly(group_member_list.length).times
                                       .and_raise(DiscourseApi::UnauthenticatedError.new(' - Not permitted to view resource.'))
      expect(mock_dependencies).to receive(:run_scans).exactly(group_member_list.length).times
      mock_dependencies
    end

    subject { MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
                                         target_groups=%w(trust_level_1), target_username=nil, mock: mock_dependencies) }

    it "responds to unknown .connect_to_instance" do
      subject.apply_to_users(scan_options)
      expect(subject).to respond_to(:apply_to_users)
    end
  end


  describe ".connect_to_instance" do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      mock_dependencies
    end

    subject { MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
                                         target_groups=%w(trust_level_1), target_username=nil, mock: mock_dependencies) }

    it "responds to live .connect_to_instance" do
      subject.connect_to_instance('KM_Admin', 'live')
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

end

