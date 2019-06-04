require_relative '../spec_helper'

describe MomentumApi::Discourse do

  do_live_updates =   false
  target_username =   nil
  target_groups   =   %w(trust_level_1) # OwnerExpired Mods GreatX BraveHearts trust_level_1 trust_level_0

  let(:group_member_list) { json_fixture("groups_members.json")[0..1]}
  let(:user_details) { json_fixture("user.json") }
  let(:category_list) { json_fixture("categories.json") }

  describe ".apply_to_users" do

    let(:mock_dependencies) do
      mock_dependencies = instance_double('mock_dependencies')
      expect(mock_dependencies).to receive(:group_members).and_return(group_member_list)
      expect(mock_dependencies).to receive(:user).and_return(user_details).exactly(group_member_list.length).times
      expect(mock_dependencies).to receive(:categories).and_return(category_list).exactly(group_member_list.length).times
      expect(mock_dependencies).to receive(:run_scans).exactly(group_member_list.length).times
      mock_dependencies
    end

    subject { MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
                                         target_groups=target_groups, target_username=target_username, mock: mock_dependencies) }

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

    it 'responds to apply_to_users and runs thru users' do
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
                                         target_groups=target_groups, target_username=target_username, mock: mock_dependencies) }
    
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

