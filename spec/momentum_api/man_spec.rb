require_relative '../spec_helper'

describe MomentumApi::Man do

  let(:group_member_list) {json_fixture("groups_members.json")[0..1]}
  let(:user_details) {json_fixture("user_details.json")}
  let(:user_details_non_owner) {json_fixture("user_details_non_owner.json")}
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
    expect(mock_schedule).to receive(:options).once.and_return(schedule_options)
    mock_schedule
  end

  let(:mock_discourse) do
    mock_discourse = instance_double('mock_discourse')
    expect(mock_discourse).to receive(:options).exactly(7).times.and_return([])
    expect(mock_discourse).to receive(:schedule).exactly(6).times.and_return(mock_schedule)
    mock_discourse
  end


  context 'a regular Owner' do

    let(:mock_discourse) do
      mock_discourse = instance_double('mock_discourse')
      expect(mock_discourse).to receive(:options).exactly(7).times.and_return(discourse_options)
      expect(mock_discourse).to receive(:schedule).exactly(13).times.and_return(mock_schedule)
      mock_discourse
    end

    describe '.scan_contexts inits Man pulls categories' do

      subject {MomentumApi::Man.new(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies)}

      it 'responds to scan_contexts and pulls categories' do
        subject.instance_variable_set(:@is_owner, true)
        subject.scan_contexts
        expect(subject).to respond_to(:scan_contexts)
        expect(subject.instance_variable_get(:@users_categories)).to be_an(Array)
      end
    end

    describe '.scan_contexts sees issue user' do

      let(:mock_discourse) do
        mock_discourse = instance_double('mock_discourse')
        reset_options = discourse_options
        reset_options[:issue_users] = %w(Tony_Christopher)
        expect(mock_discourse).to receive(:options).exactly(7).times.and_return(reset_options)
        expect(mock_discourse).to receive(:schedule).exactly(13).times.and_return(mock_schedule)
        mock_discourse
      end

      let(:man) { man_is_owner(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies) }

      it 'responds to scan_contexts and prints issue user' do
        expect { man.scan_contexts }
            .to output(/Tony_Christopher in scan_contexts/).to_stdout
      end
    end
  end


  context 'a non-Owner' do

    let(:mock_discourse) do
      mock_discourse = instance_double('mock_discourse')
      expect(mock_discourse).to receive(:options).exactly(6).times.and_return(discourse_options)
      expect(mock_discourse).to receive(:schedule).exactly(12).times.and_return(mock_schedule)
      mock_discourse
    end

    let(:mock_schedule) do
      mock_schedule = instance_double('mock_schedule')
      expect(mock_schedule).to receive(:group_cases).exactly(5).times
      expect(mock_schedule).to receive(:category_cases).exactly(5).times
      expect(mock_schedule).to receive(:options).once.and_return(schedule_options)
      expect(mock_schedule).to receive(:downgrade_non_owner_trust).once
      mock_schedule
    end
    
    describe '.scan_contexts inits w/o categories' do

      let(:non_owner) {MomentumApi::Man.new(mock_discourse, mock_dependencies,
                                            user_details_non_owner, mock: mock_dependencies)}

      it 'responds to scan_contexts and update_user_trust_level for non-owner' do
        non_owner.instance_variable_set(:@is_owner, false)
        non_owner.scan_contexts
        expect(non_owner).to respond_to(:scan_contexts)
        expect(non_owner.instance_variable_get(:@users_categories)).to be_an(Array)
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
        expect(mock_schedule).to receive(:options).once.and_return(schedule_options)
        mock_schedule
      end

      let(:mock_discourse) do
        mock_discourse = instance_double('mock_discourse')
        expect(mock_discourse).to receive(:options).exactly(7).times.and_return(discourse_options)
        expect(mock_discourse).to receive(:schedule).exactly(7).times.and_return(mock_schedule)
        mock_discourse
      end

      let(:man) { man_is_owner(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies) }
      
      it 'responds to scan_contexts and inits' do
        man.scan_contexts
        expect(man).to respond_to(:scan_contexts)
        expect(man.instance_variable_get(:@users_categories)).to be_nil
      end
    end
  end


  context 'print_user_options' do

    describe '.print_user_options' do

      let(:user_option_print) { %w(last_seen_at last_posted_at post_count time_read recent_time_read user_field_score) }

      let(:mock_discourse) do
        mock_discourse = instance_double('mock_discourse')
        mock_discourse
      end

      let(:man) {MomentumApi::Man.new(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies)}
      
      it 'responds and prints user' do
        expect { man.print_user_options(user_details, user_option_print) }
            .to output(/last_seen_at/).to_stdout

      end
    end

  end

end

