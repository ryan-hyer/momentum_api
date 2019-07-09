require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter])

SimpleCov.start do
  add_filter "/spec/"
end

require 'momentum_api'
require 'rspec'
require 'json'
require 'webmock/rspec'


class MockLogger
  def initialize(*targets)
    # @targets = targets
  end

  def warn(to_stand_out)
    puts to_stand_out
  end

  def info(to_stand_out)
    puts to_stand_out
  end

  # def close
  #   @targets.each(&:close)
  # end
end

# log_file = File.open("scan.log", "a")
logger = MockLogger.new

def discourse_options
  {
      do_live_updates:              false,
      target_username:              nil,
      target_groups:                %w(trust_level_1),
      instance:                     'live',
      api_username:                 'KM_Admin',
      exclude_users:                %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin),
      issue_users:                  %w(),
      logger:                       MockLogger.new
  }
end

def schedule_options
  {
      category:{
          matching_team:              {
              allowed_levels:         [3],
              set_level:               3,
              excludes:               %w(Steve_Scott Ryan_Hyer David_Kirk)
          },
          essential:                  {
              allowed_levels:         [3],
              set_level:               3,
              excludes:               %w(Steve_Scott Joe_Sabolefski)
          },
          growth:                     {
              allowed_levels:         [3, 4],
              set_level:               4,
              excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
          },
          meta:                       {
              allowed_levels:         [3, 4],
              set_level:               4,
              excludes:               %w(Joe_Sabolefski Bill_Herndon Michael_Wilson Howard_Bailey Steve_Scott)
          }
      },
      group:{
          group_alias:                {
              allowed_levels:         nil,
              set_level:              nil,
              excludes:               %w()
          }
      },
      user:{
          preferences:                              {
              user_option: {
                  email_messages_level: {
                    do_task_update:         false,
                    allowed_levels:         0,
                    set_level:              0,
                    excludes:               %w()
                  }
              },
              user_fields: {
                  user_fields: {
                    do_task_update:         false,
                    allowed_levels:         '0',
                    set_level:              {'5':'0'},
                    excludes:               %w()
                  }
              }
          },
          downgrade_non_owner_trust:                {
              do_task_update:         false,
              allowed_levels:         0,
              set_level:              0,
              excludes:               %w()
          }
      },
      user_scores: {
          update_type:              'not_voted', # have_voted, not_voted, newly_voted, all
          target_post:              30719,       # 28707 28649
          # target_polls:           %w(poll),    # basic new version_two
          poll_url:                 'https://discourse.gomomentum.org/t/what-s-your-score',
          messages_from:            'Kim_Miller',
          excludes:                 %w()
      }
  }
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def json_fixture(json_file)
  json_object = File.read(fixture_path + '/' + json_file)
  JSON.parse(json_object)
end

def man_is_owner(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies)
  man = MomentumApi::Man.new(mock_discourse, mock_dependencies, user_details, mock: mock_dependencies)
  man.instance_variable_set(:@is_owner, true)
  man
end