require '../utility/momentum_api'

@do_live_updates = false
client = connect_to_instance('live') # 'live' or 'local'

# testing variables
# @target_username = 'Rich_Worthington'
@issue_users = %w() # debug issue user_names

@user_option_targets = {
    'mailing_list_mode': false, # Enable mailing list mode
    # 'email_direct': true,       # Send me an email when someone quotes me, replies to my post, mentions my @username, or invites me to a topic
}

@user_option_print = %w(
    last_seen_at
    last_posted_at
    post_count
    time_read
    recent_time_read
    mailing_list_mode
)

@target_groups = %w(trust_level_0)
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin)
@field_settings = "%-18s %-14s %-16s %-12s %-12s %-17s %-14s\n"

@user_count, @user_targets, @users_updated = 0, 0, 0, 0

def print_user_options(user_details)
  printf @field_settings, @users_username,
         user_details[@user_option_print[0].to_s].to_s[0..9], user_details[@user_option_print[1].to_s].to_s[0..9],
         user_details[@user_option_print[2].to_s], user_details[@user_option_print[3].to_s],
         user_details[@user_option_print[4].to_s], user_details['user_option'][@user_option_print[5].to_s]
end

# standardize_email_settings
def apply_function(client, user)  # TODO 1. Run mailing list mode update, Eric_Nitzberg, 2. push to mother
  @users_username = user['username']
  @user_count += 1
  user_details = client.user(@users_username)
  user_groups = user_details['groups']
  user_option = user_details['user_option']

  user_groups.each do |group|
    @group_name = group['name']
    if @issue_users.include?(@users_username)
      puts "\n#{@users_username}  Group: #{@group_name}\n"
    end

    if @target_groups.include?(@group_name)
      all_settings_true = [user_option[@user_option_targets.keys[0].to_s]].all?
      if not all_settings_true
        # puts 'All settings are correct'
      else
        print_user_options(user_details)
        @user_targets += 1
        if @do_live_updates
          update_response = client.update_user(@users_username, @user_option_targets)
          puts update_response[:body]['success']
          @users_updated += 1

          # check if update happened
          user_details_after_update = client.user(@users_username)
          print_user_options(user_details_after_update)
          sleep(1)
        end
      end
    end
    break
  end
end

printf @field_settings, 'UserName',
       @user_option_print[0], @user_option_print[1], @user_option_print[2],
       @user_option_print[3], @user_option_print[4], @user_option_print[5]

apply_to_all_users(client)

puts "\n#{@users_updated} users updated out of #{@user_targets} possible targets out of #{@user_count} total users."

# Feb 28, 2019`
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  mailing_list_mode
# Curt_Weil          2019-02-28     2019-02-26       96           9189         145               true
# Randy_Horton       2019-02-28     2019-02-27       255          14484        5739              true
# Paul_Tyner         2019-02-28     2019-01-14       34           35763        4961              true
# Rich_Worthington   2019-02-28     2019-02-28       93           40939        6620              true
# Marty_Fauth        2019-02-28     2019-02-25       295          100485       10822             true
# Anshu_Sanghi       2019-02-28     2019-01-23       72           45285        154               true
# Charlie_Bedard     2019-02-27     2019-02-21       67           10257        741               true
# Stefan_Schmitz     2019-02-27     2019-02-27       68           78925        19018             true
# Jerry_Strebig      2019-02-27     2019-02-27       159          6139         336               true
# Jeff_Cintas        2019-02-27     2019-01-31       37           39790        386               true
# John_Oberstar      2019-02-26     2019-02-26       24           8005         1729              true
# Russ_Towne         2019-02-26     2019-02-26       124          11003        3794              true
# Bob_Richards       2019-02-26     2018-10-14       8            386          72                true
# Edmond_Cote        2019-02-26     2019-02-25       194          78772        7996              true
# Mike_Weston        2019-02-26     2019-02-18       25           22840        4428              true
# Mike_Ehlers        2019-02-26     2019-01-09       13           12431        349               true
# Tom_Feasby         2019-02-26     2019-02-28       157          19902        1485              true
# Mitch_Slomiak      2019-02-26     2019-02-27       141          4637         0                 true
# Jim_Knapp          2019-02-21     2019-02-21       150          3996         185               true
# Steve_Cross        2019-02-20     2019-02-26       50           4746         936               true
# Laurence_Kuhn      2019-02-18     2019-02-18       108          11734        418               true
# Rick_Kananen       2019-02-16     2019-02-16       24           534          168               true
# Jim_Leney          2019-02-16     2018-04-13       24           6219         71                true
# Steve_Fitzsimons   2019-02-15     2019-02-25       123          2679         73                true
# Joseph_Kuo         2019-02-14     2019-01-02       3            2595         885               true
# Marco_Milletti     2019-02-11     2018-10-11       0            11372        309               true
# Juergen_Weltz      2019-02-10     2018-12-05       5            5186         199               true
# Roger_Chapman      2019-02-10     2019-02-10       11           1864         353               true
# Miles_Bradley      2019-02-10     2019-02-25       232          48054        1371              true
# Garry_Cheney       2019-02-05     2019-02-11       75           1472         324               true
# Brad_Peppard       2019-01-15     2019-02-05       17           8675         752               true
# Vern_Mcgeorge      2019-01-13     2018-11-14       11           1898         0                 true
# Flint_Thorne       2019-01-11     2019-01-09       13           3242         21                true
# Mark_Habberley     2019-01-10     2018-04-25       3            1021         0                 true
# Doug_Greig         2019-01-10     2019-01-10       29           9884         494               true
# Ron_Tugender       2018-12-20     2018-12-09       68           37760        0                 true
# Gene_Sussli        2018-12-14     2019-02-09       28           13261        0                 true
# Tesh_Tesfaye       2018-09-13     2016-12-21       1            567          0                 true
# Butch_Dority       2018-08-13                      0            1196         0                 true
# Curt_Haynes        2018-05-16     2018-05-02       17           3750         0                 true
# Dennis_Sorensen    2018-04-13     2018-08-23       6            1644         0                 true
# Jack_Shannon       2018-02-18     2018-01-03       1            42           0                 true
# Ravi_Narra         2018-01-09     2017-12-31       11           7130         0                 true
# Maarten_Korringa   2018-01-06     2017-01-20       1            3712         0                 true
# Lars_Rider         2018-01-05     2019-01-18       154          7014         0                 true
# Bill_Heller        2017-12-28     2019-02-07       9            1529         0                 true
# Steve_Benjamin     2017-11-16     2016-11-26       0            857          0                 true
# Al_Dorji           2017-08-09                      0            10           0                 true
# Stephen_Gorman     2017-07-19     2017-04-11       2            2507         0                 true
# Udy_Gold           2017-01-13     2017-01-20       12           1023         0                 true
# Bill_Strahm        2016-11-24     2018-10-10       6            1562         0                 true
#
# 0 users updated out of 51 possible targets and 203 users total.