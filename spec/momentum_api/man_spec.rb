require_relative '../spec_helper'

describe MomentumApi::Man do

  let(:group_member_list) {json_fixture("groups_members.json")[0..1]}
  let(:user_details) {json_fixture("user_details.json")}
  let(:category_list) {json_fixture("categories.json")}

  let(:mock_dependencies) do
    mock_dependencies = instance_double('mock_dependencies')
    expect(mock_dependencies).to receive(:categories).and_return(category_list).once
    mock_dependencies
  end

  let(:mock_schedule) do
    mock_schedule = instance_double('mock_schedule')
    expect(mock_schedule).to receive(:group_cases).exactly(6).times
    expect(mock_schedule).to receive(:category_cases).exactly(6).times
    mock_schedule
  end

  let(:mock_discourse) do
    mock_discourse = instance_double('mock_discourse')
    expect(mock_discourse).to receive(:issue_users).exactly(7).times.and_return([])
    expect(mock_discourse).to receive(:schedule).exactly(6).times.and_return(mock_schedule)
    mock_discourse
  end


  context 'one regular user' do

    let(:mock_discourse) do
      mock_discourse = instance_double('mock_discourse')
      expect(mock_discourse).to receive(:issue_users).exactly(7).times.and_return([])
      expect(mock_discourse).to receive(:schedule).exactly(12).times.and_return(mock_schedule)
      mock_discourse
    end

    describe '.membership_scan inits Man and pulls categories' do

      subject {MomentumApi::Man.new(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies)}

      it 'responds to membership_scan and inits' do
        subject.scan_contexts
        expect(subject).to respond_to(:scan_contexts)
        expect(subject.instance_variable_get(:@users_categories)).to be_an(Array)
      end
    end

    describe '.membership_scan sees issue user' do

      let(:mock_discourse) do
        mock_discourse = instance_double('mock_discourse')
        expect(mock_discourse).to receive(:issue_users).exactly(7).times.and_return(%w(Tony_Christopher))
        expect(mock_discourse).to receive(:schedule).exactly(12).times.and_return(mock_schedule)
        mock_discourse
      end

      subject { MomentumApi::Man.new(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies) }

      it 'responds to apply_to_users and runs thru group of users' do
        expect { subject.scan_contexts }
            .to output(/Tony_Christopher in membership_scan/).to_stdout
      end
    end
  end

   
  context 'errors present' do

    describe "client.categories DiscourseApi::TooManyRequests x2 raises error" do

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:categories).exactly(2).times
                                         .and_raise(DiscourseApi::TooManyRequests.new('error message here'))
        mock_dependencies
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('mock_discourse')
        mock_discourse
      end

      subject {MomentumApi::Man.new(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies)}

      it "responds to unknown .connect_to_instance" do
        expect { subject.scan_contexts }.to raise_error(DiscourseApi::TooManyRequests)
      end
    end


    describe "client.categories may raise DiscourseApi::UnauthenticatedError and still run scan" do

      let(:mock_dependencies) do
        mock_dependencies = instance_double('mock_dependencies')
        expect(mock_dependencies).to receive(:categories).once
                                         .and_raise(DiscourseApi::UnauthenticatedError.new('error message here'))
        mock_dependencies
      end

      let(:mock_schedule) do
        mock_schedule = instance_double('mock_schedule')
        expect(mock_schedule).to receive(:group_cases).exactly(6).times
        mock_schedule
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('mock_discourse')
        expect(mock_discourse).to receive(:issue_users).exactly(7).times.and_return([])
        expect(mock_discourse).to receive(:schedule).exactly(6).times.and_return(mock_schedule)
        mock_discourse
      end

      subject {MomentumApi::Man.new(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies)}

      it 'responds to membership_scan and inits' do
        subject.scan_contexts
        expect(subject).to respond_to(:scan_contexts)
        expect(subject.instance_variable_get(:@users_categories)).to be_nil
      end
    end
  end

end

