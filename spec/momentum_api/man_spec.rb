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

    # let(:mock_dependencies) do
    #   mock_dependencies = instance_double('mock_dependencies')
    #   expect(mock_dependencies).to receive(:categories).and_return(category_list).once
    #   mock_dependencies
    # end

    let(:mock_schedule) do
      mock_schedule = instance_double('mock_schedule')
      expect(mock_schedule).to receive(:category_cases).exactly(6).times
      mock_schedule
    end

    let(:mock_discourse) do
      mock_discourse = instance_double('mock_discourse')
      expect(mock_discourse).to receive(:issue_users).exactly(7).times.and_return([])
      expect(mock_discourse).to receive(:schedule).exactly(6).times.and_return(mock_schedule)
      mock_discourse
    end

    describe '.membership_scan inits Man and pulls categories' do

      subject {MomentumApi::Man.new(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies)}

      it 'responds to membership_scan and inits' do
        subject.membership_scan
        expect(subject).to respond_to(:membership_scan)
        expect(subject.instance_variable_get(:@users_categories)).to be_an(Array)
      end
    end

    describe '.membership_scan sees issue user' do

      let(:mock_discourse) do
        mock_discourse = instance_double('mock_discourse')
        expect(mock_discourse).to receive(:issue_users).exactly(7).times.and_return(%w(Tony_Christopher))
        expect(mock_discourse).to receive(:schedule).exactly(6).times.and_return(mock_schedule)
        mock_discourse
      end

      subject { MomentumApi::Man.new(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies) }

      it 'responds to apply_to_users and runs thru group of users' do
        expect { subject.membership_scan }
            .to output(/Tony_Christopher in membership_scan/).to_stdout
      end
    end
  end


  context 'regular group of users' do
    # end
    #
    #
    # context 'a single user' do
    #
    #   describe '.apply_to_users single user' do
    #
    #     let(:mock_dependencies) do
    #       mock_dependencies = instance_double('mock_dependencies')
    #       expect(mock_dependencies).to receive(:group_members).and_return(group_member_list)
    #       expect(mock_dependencies).to receive(:user).and_return(user_details).once
    #       expect(mock_dependencies).to receive(:membership_scan).once
    #       mock_dependencies
    #     end
    #
    #     discourse_single_user_option = discourse_options
    #     discourse_single_user_option[:target_username] = 'Tony_Christopher'
    #     subject { MomentumApi::Discourse.new(discourse_single_user_option, schedule_options, mock: mock_dependencies) }
    #
    #     it 'runs single user and responds to apply_to_users' do
    #       subject.apply_to_users(schedule_options)
    #       expect(subject).to respond_to(:apply_to_users)
    #       expect(subject.instance_variable_get(:@discourse_counters)[:'Processed Users']).to eql(1)
    #     end
    #   end
    # end


    context 'errors are raised' do

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
          expect { subject.membership_scan }.to raise_error(DiscourseApi::TooManyRequests)
        end
      end


      describe "client.categories may raise DiscourseApi::UnauthenticatedError and still run scan" do

        let(:mock_dependencies) do
          mock_dependencies = instance_double('mock_dependencies')
          expect(mock_dependencies).to receive(:categories).once
                                           .and_raise(DiscourseApi::UnauthenticatedError.new('error message here'))
          mock_dependencies
        end

        let(:mock_discourse) do
          mock_discourse = instance_double('mock_discourse')
          expect(mock_discourse).to receive(:issue_users).exactly(7).times.and_return([])
          mock_discourse
        end
        
        subject {MomentumApi::Man.new(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies)}

        it 'responds to membership_scan and inits' do
          subject.membership_scan
          expect(subject).to respond_to(:membership_scan)
          expect(subject.instance_variable_get(:@users_categories)).to be_nil
          # expect(subject.instance_variable_get(:@discourse)[:discourse_counters][:'Processed Users']).to eql(1)
        end
      end
    end

    # context 'staged users' do
    #
    #   describe '.apply_to_users skips staged user' do
    #
    #     let(:group_member_list) { json_fixture("groups_members.json")}
    #     let(:staged_user_details) { json_fixture("user_staged.json") }
    #
    #     let(:mock_dependencies) do
    #       mock_dependencies = instance_double('mock_dependencies')
    #       expect(mock_dependencies).to receive(:group_members).and_return(group_member_list)
    #       expect(mock_dependencies).to receive(:user).and_return(staged_user_details).once
    #       mock_dependencies
    #     end
    #
    #     discourse_staged_user_option = discourse_options
    #     discourse_staged_user_option[:target_username] = 'Noah_Salzman'
    #     subject { MomentumApi::Discourse.new(discourse_staged_user_option, schedule_options, mock: mock_dependencies) }
    #
    #     it 'skips staged users and responds to apply_to_users' do
    #       subject.apply_to_users(schedule_options)
    #       expect(subject).to respond_to(:apply_to_users)
    #       expect(subject.instance_variable_get(:@discourse_counters)[:'Skipped Users']).to eql(1)
    #     end
    #   end
    # end
    #
    # context 'final scan summary' do
    #
    #   let(:mock_dependencies) do
    #     mock_dependencies = instance_double('mock_dependencies')
    #     mock_dependencies
    #   end
    #
    #   describe ".connect_to_instance" do
    #
    #     subject { MomentumApi::Discourse.new(discourse_options, schedule_options, mock: mock_dependencies) }
    #
    #     it "responds to live .connect_to_instance" do
    #       subject.connect_to_instance('KM_Admin', 'live')
    #       expect(subject).to respond_to(:connect_to_instance)
    #     end
    #
    #     it "responds to local .connect_to_instance" do
    #       subject.connect_to_instance('KM_Admin', 'local')
    #       expect(subject).to respond_to(:connect_to_instance)
    #     end
    #
    #     it "responds to unknown .connect_to_instance" do
    #       expect { subject.connect_to_instance('KM_Admin', 'some_unknown') }
    #           .to raise_error('Host unknown error has occured')
    #     end
    #   end
    #
    #   describe ".scan_summary should tally counter totals" do
    #
    #     subject { MomentumApi::Discourse.new(discourse_options, schedule_options, mock: mock_dependencies) }
    #
    #     it "responds to .scan_summary and find 0 init" do
    #       subject.scan_summary
    #       expect(subject).to respond_to(:scan_summary)
    #       expect(subject.instance_variable_get(:@discourse_counters)[:'Processed Users']).to eql(0)
    #     end
    #
    #     it "responds to .scan_summary and print to stand out" do
    #       subject.scan_summary
    #       expect(subject).to respond_to(:scan_summary)
    #       expect { subject.scan_summary }.to output(/Discourse Men/).to_stdout
    #     end
    #   end
  end
end

