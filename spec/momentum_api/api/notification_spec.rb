require_relative '../../spec_helper'

describe MomentumApi::Notification do
  subject { MomentumApi::Man.new('user_client', 'user_details', users_categories='users_categories' )}

  describe "#set_category_notification" do
    # before do
    #   stub_get("http://localhost:3000/admin/badges.json").to_return(body: fixture("badges.json"), headers: { content_type: "application/json" })
    # end


    it "requests the correct resource" do
      # subject.run_scans('')
      # subject.set_category_notification('category', 'group_name', [3], 3)
      # expect(a_get("http://localhost:3000/admin/badges.json")).to have_been_made
    end

    # it "requests the correct resource" do
    #   subject.discourse.do_live_updates = false
    #   subject.set_category_notification('category', 'group_name', [3], 3)
    #   # expect(a_get("http://localhost:3000/admin/badges.json")).to have_been_made
    # end

    # it "returns the requested badges" do
    #   badges = subject.badges
    #   expect(badges).to be_a Hash
    #   expect(badges['badges']).to be_an Array
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

