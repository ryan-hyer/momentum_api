require_relative '../spec_helper'

describe MomentumApi::Discourse do

  let(:group_member_list) { json_fixture("groups_members.json")[0..1]}

  let(:user_details) { json_fixture("user.json") }

  let(:category_list) { json_fixture("categories.json") }

  let(:mock_dependencies) do
    mock_dependencies = instance_double('mock_dependencies')
    expect(mock_dependencies).to receive(:group_members).and_return(group_member_list)
    expect(mock_dependencies).to receive(:user).and_return(user_details).exactly(group_member_list.length).times
    expect(mock_dependencies).to receive(:categories).and_return(category_list).exactly(group_member_list.length).times
    expect(mock_dependencies).to receive(:run_scans).exactly(group_member_list.length).times
    mock_dependencies
  end

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

  do_live_updates =   false
  target_username =   nil
  target_groups   =   %w(trust_level_1) # OwnerExpired Mods GreatX BraveHearts trust_level_1 trust_level_0

  subject { MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
                                       target_groups=target_groups, target_username=target_username, mock: mock_dependencies) }
  # before(:example) do
  #   @subject = MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
  #                                       target_groups=target_groups, target_username=target_username, mock: mock_dependencies)
  # end

  it ".apply_to_users" do
    subject.apply_to_users(scan_options)
    expect(subject).to respond_to(:apply_to_users)
    # expect(subject).to respond_to(:group_members)
  end

  it ".apply_to_users" do
    subject.apply_to_users(scan_options)
    expect(subject).to respond_to(:apply_to_users)
    # expect(subject).to respond_to(:group_members)
  end

  # it ".apply_to_users" do
  #   subject.apply_to_users(scan_options)
  #   expect(subject).to respond_to(:apply_to_users)
  #   # expect(subject).to respond_to(:group_members)
  # end

  it ".connect_to_instance" do
    # subject.connect_to_instance('KM_Admin')
    # expect(subject).to respond_to(:connect_to_instance)
  end



  describe "#set_category_notification" do
 
    # before :each do
    #     @discourse = MomentumApi::Discourse.new('KM_Admin', 'live', do_live_updates = do_live_updates,
    #                                             target_groups=target_groups, target_username=target_username, admin_client=mock_dependencies)
    #   end
    #   # connect_to_instance = double("connect_to_instance")
    # end
    #
    # subject { @discourse }

    # it ".connect_to_instance" do
    #   subject.connect_to_instance('KM_Admin')
    #   expect(subject).to respond_to(:connect_to_instance)
    # end

    # it "#.apply_to_users" do
    #   expect(@discourse).to respond_to(:apply_to_users)
    # end
    #
    # it "#.apply_to_group_users" do
    #   expect(@discourse).to respond_to(:apply_to_group_users)
    # end

  end

  # describe "#user-badges" do
  #   before do
  #     stub_get("http://localhost:3000/user-badges/test_user.json").to_return(body: fixture("user_badges.json"), headers: { content_type: "application/json" })
  #   end
  #
  #   it "requests the correct resource" do
  #     subject.user_badges('test_user')
  #     expect(a_get("http://localhost:3000/user-badges/test_user.json")).to have_been_made
  #   end
  #
  #   it "returns the requested user badges" do
  #     badges = subject.user_badges('test_user')
  #     expect(badges).to be_an Array
  #     expect(badges.first).to be_a Hash
  #     expect(badges.first).to have_key('badge_type_id')
  #   end
  # end
end

