# require_relative 'log/ib/momentum_api/utility'
require '../lib/momentum_api'

discourse_options = {
    do_live_updates:        true,
    target_username:        'Kim_Miller',     # David_Kirk Steve_Scott Marty_Fauth Kim_Miller David_Ashby
    target_groups:          %w(trust_level_1),       # Mods GreatX BraveHearts trust_level_1
    ownership_groups:       %w(Owner Owner_Manual),
    instance:               'https://discourse.gomomentum.org',
    api_username:           'KM_Admin',
    exclude_users:           %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin MD_Admin),
    issue_users:             %w(),
    log_file:                File.expand_path('../logs/_run.log', __FILE__)
}

schedule_options = {
    user:{
        preferences:                              {
            user_option: {
                mailing_list_mode: {
                    do_task_update:         true,
                    allowed_levels:         false,
                    set_level:              false,
                    excludes:               %w(David_Kirk)
                }
            }
        }
    }
}

discourse_options[:logger] = momentum_api_logger(discourse_options[:log_file])
discourse = MomentumApi::Discourse.new(discourse_options, schedule_options: schedule_options)
discourse.apply_to_users
discourse.scan_summary

# puts "\n#{@users_updated} users updated out of #{@user_targets} possible targets out of #{@user_count} total users."

# Apr 12, 2019
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  mailing_list_mode
# Laurence_Kuhn      2019-04-12     2019-04-02       108          11734        60                true
# Stefan_Schmitz     2019-04-12     2019-04-11       73           92565        20703             true
# Rich_Worthington   2019-04-12     2019-04-10       95           44418        4942              true
# Marty_Fauth        2019-04-12     2019-04-12       320          116572       20998             true
# Paul_Tyner         2019-04-12     2019-03-11       37           39091        3969              true
# Jeff_Cintas        2019-04-11     2019-01-31       37           40372        582               true
# Edmond_Cote        2019-04-11     2019-04-08       209          86034        11491             true
# John_Oberstar      2019-04-11     2019-04-03       27           12488        5385              true
# Mitch_Slomiak      2019-04-10     2019-04-08       148          5027         390               true
# Jim_Knapp          2019-04-10     2019-04-08       157          4037         41                true
# Miles_Bradley      2019-04-09     2019-04-12       242          49065        1011              true
# Mike_Weston        2019-04-08     2019-04-08       28           26522        5932              true
# Russ_Towne         2019-04-08     2019-04-09       132          11947        1434              true
# Marco_Milletti     2019-04-04     2018-10-11       0            12703        1425              true
# Joseph_Kuo         2019-04-03     2019-03-11       3            2979         568               true
# Randy_Horton       2019-04-02     2019-04-08       285          18461        5870              true
# Anshu_Sanghi       2019-03-29     2019-01-23       72           45285        100               true
# Curt_Weil          2019-03-26     2019-04-03       106          10687        1544              true
# Tom_Feasby         2019-03-25     2019-04-09       176          22118        2265              true
# Garry_Cheney       2019-03-23     2019-04-08       79           1574         102               true
# Charlie_Bedard     2019-03-22     2019-03-28       67           10794        1278              true
# Ron_Tugender       2019-03-22     2018-12-09       68           37760        0                 true
# Jerry_Strebig      2019-03-21     2019-03-31       173          6490         504               true
# Vern_Mcgeorge      2019-03-21     2018-11-14       11           2032         134               true
# Mike_Ehlers        2019-03-15     2019-01-09       13           12431        0                 true
# Flint_Thorne       2019-03-12     2019-03-31       19           4046         804               true
# Juergen_Weltz      2019-03-11     2018-12-05       5            5258         72                true
# Doug_Greig         2019-03-09     2019-03-09       30           10121        237               true
# Roger_Chapman      2019-03-08     2019-02-10       11           1864         0                 true
# Bob_Richards       2019-02-26     2018-10-14       8            386          25                true
# Rick_Kananen       2019-02-16     2019-03-22       28           534          125               true
# Jim_Leney          2019-02-16     2018-04-13       24           6219         71                true
# Mark_Habberley     2019-01-10     2018-04-25       3            1021         0                 true
# Gene_Sussli        2018-12-14     2019-02-09       28           13261        0                 true
# Tesh_Tesfaye       2018-09-13     2016-12-21       1            567          0                 true
# Butch_Dority       2018-08-13                      0            1196         0                 true
# Curt_Haynes        2018-05-16     2018-05-02       17           3750         0                 true
# Dennis_Sorensen    2018-04-13     2019-04-08       7            1644         0                 true
# Jack_Shannon       2018-02-18     2018-01-03       1            42           0                 true
# Ravi_Narra         2018-01-09     2017-12-31       11           7130         0                 true
# Maarten_Korringa   2018-01-06     2017-01-20       1            3712         0                 true
# Lars_Rider         2018-01-05     2019-04-08       156          7014         0                 true
# Bill_Heller        2017-12-28     2019-02-07       9            1529         0                 true
# Steve_Benjamin     2017-11-16     2016-11-26       0            857          0                 true
# Al_Dorji           2017-08-09                      0            10           0                 true
# Stephen_Gorman     2017-07-19     2017-04-11       2            2507         0                 true
# Udy_Gold           2017-01-13     2017-01-20       12           1023         0                 true
# Bill_Strahm        2016-11-24     2018-10-10       6            1562         0                 true
#
# 0 users updated out of 48 possible targets out of 201 total users.
#
# Process finished with exit code 0