require '../utility/momentum_api'

@do_live_updates = false
client = connect_to_instance('live') # 'live' or 'local'

# testing variables
# @target_username = 'KM_Admin'
@issue_users = %w() # debug issue user_names

@user_option_targets = {
    'homepage_id': 2, # Enable mailing list mode
    # 'email_direct': true,       # Send me an email when someone quotes me, replies to my post, mentions my @username, or invites me to a topic
}

@user_option_print = %w(
    last_seen_at
    last_posted_at
    post_count
    time_read
    recent_time_read
    homepage_id
)

@target_groups = %w(trust_level_0)
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin )
@field_settings = "%-18s %-14s %-16s %-12s %-12s %-17s %-14s\n"

@user_count, @user_targets, @users_updated = 0, 0, 0, 0

def print_user_options(user_details)
  printf @field_settings, @users_username,
         user_details[@user_option_print[0].to_s].to_s[0..9], user_details[@user_option_print[1].to_s].to_s[0..9],
         user_details[@user_option_print[2].to_s], user_details[@user_option_print[3].to_s],
         user_details[@user_option_print[4].to_s], user_details['user_option'][@user_option_print[5].to_s]
end

# standardize_email_settings
def apply_function(client, user)  # TODO 1. update homepage_id
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
      # what to update
      value_setting_true = user_option[@user_option_targets.keys[0].to_s] == nil
      all_settings_true = [user_option[@user_option_targets.keys[0].to_s]].all?
      if not value_setting_true
        # puts 'All settings are correct'
        print_user_options(user_details)
      else
        # print_user_options(user_details)
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
      break
    end
  end
end

printf @field_settings, 'UserName',
       @user_option_print[0], @user_option_print[1], @user_option_print[2],
       @user_option_print[3], @user_option_print[4], @user_option_print[5]

apply_to_all_users(client)

puts "\n#{@users_updated} users updated out of #{@user_targets} possible targets out of #{@user_count} total users."

# Mar 2, 2019
# UserName           last_seen_at   last_posted_at   post_count   time_read    recent_time_read  homepage_id
# Stefan_Schmitz     2019-03-02     2019-03-02       69           79278        19281
# Moe_Rubenzahl      2019-03-02     2019-03-02       642          255742       87045
# Joe_Sabolefski     2019-03-02     2019-01-20       197          294915       16684
# Jim_Charley        2019-03-02     2019-03-01       327          163134       18894
# Sanjeev_Sanghera   2019-03-02     2019-02-12       15           21836        6293
# Jerry_Strebig      2019-03-02     2019-03-02       159          6163         360
# Marty_Fauth        2019-03-02     2019-02-25       295          100570       10907
# Gary_Merrick       2019-03-02     2019-02-28       236          241080       38840
# Jack_McInerney     2019-03-02     2019-02-26       150          226360       37469
# David_Kirk         2019-03-02     2019-03-02       215          179140       19729
# Mark_Reinheimer    2019-03-02     2019-02-28       52           32451        2407
# Chris_Sulek        2019-03-02     2019-02-25       133          260741       58698
# Chris_Steck        2019-03-02     2019-03-01       112          180619       31763
# Bill_Zabor         2019-03-02     2019-02-25       97           76907        7441
# Steve_Cross        2019-03-02     2019-02-26       50           4746         763
# Robbie_Bow         2019-03-02     2019-02-01       33           26396        7085
# James_McKeefery    2019-03-02                      0            55           0
# Eric_Nitzberg      2019-03-02     2019-03-02       0            58           58
# Benjamin_Berman    2019-03-02     2019-03-02       42           35358        4910
# John_Butler        2019-03-02     2019-02-27       139          5559         459
# John_Oberstar      2019-03-02     2019-03-01       25           8468         2192
# Ryan_Hyer          2019-03-02     2019-02-28       492          340290       65095
# Jeff_Cintas        2019-03-01     2019-01-31       37           39790        176
# Curt_Weil          2019-03-01     2019-02-26       96           9189         145
# Mike_Drilling      2019-03-01     2019-02-18       388          125225       14624
# Rich_Worthington   2019-03-01     2019-02-28       93           40942        6623
# John_Mansperger    2019-03-01     2019-02-25       108          62410        9594
# Dainuri            2019-03-01     2019-02-26       2            5372         5372
# Jim_Georgiou       2019-03-01     2019-02-25       88           92594        7939
# David_Ashby        2019-03-01     2019-03-02       25           14980        4060
# Jeff_Colvin        2019-03-01     2019-01-25       5            1438         461
# James_Grubinskas   2019-03-01     2019-03-01       2            254          254
# Randy_Horton       2019-02-28     2019-02-27       255          14484        5739
# John_Lasersohn     2019-02-28     2019-02-28       163          31814        685
# Paul_Tyner         2019-02-28     2019-01-14       34           35763        4961
# Andrew_Webster     2019-02-28     2019-02-01       55           20553        652
# Bill_Herndon       2019-02-28     2019-01-26       12           7741         176
# James_Fitzgerald   2019-02-28     2019-02-18       0            33501        17760
# Michael_Hayes      2019-02-28     2018-10-16       16           3805         66
# Art_Muir           2019-02-28     2019-02-26       23           17412        390
# Anshu_Sanghi       2019-02-28     2019-01-23       72           45285        154
# Krishna_Yetchina   2019-02-28     2019-01-17       113          150646       17838
# Charlie_Bedard     2019-02-27     2019-02-21       67           10257        741
# Mark_Thorpe        2019-02-27     2019-02-27       318          214583       6312
# Suhas_Chelian      2019-02-27     2019-02-26       5            4087         4087
# Charlie_Ohanlon    2019-02-27     2019-02-28       95           27928        2853              3
# Mikhail_Zhidko     2019-02-27     2019-02-21       86           79021        4042
# Clay_Campbell      2019-02-27     2019-02-15       39           53942        6504
# Brian_Haskin       2019-02-27     2019-01-18       35           38163        2909
# Bill_Sprague       2019-02-27                      0            1810         1446
# Ken_Cahill         2019-02-27     2019-02-11       72           103558       4328
# Jeff_Klay          2019-02-27     2019-02-20       6            3227         1282
# Mike_Druke         2019-02-26     2018-12-04       4            903          0
# Russ_Towne         2019-02-26     2019-02-26       124          11003        3794
# Bob_Richards       2019-02-26     2018-10-14       8            386          72
# Edmond_Cote        2019-02-26     2019-02-25       194          78772        7996
# Dave_Strigler      2019-02-26     2017-10-18       7            63032        8138
# Cole_Cameron       2019-02-26     2019-03-01       17           10133        2530
# Pete_Rabbitt       2019-02-26     2019-01-31       10           7217         1109
# Mike_Weston        2019-02-26     2019-02-18       25           22840        3811
# John_Doodokyan     2019-02-26     2019-02-04       0            463          396
# Mike_Ehlers        2019-02-26     2019-01-09       13           12431        349
# Tom_Feasby         2019-02-26     2019-02-28       157          19902        1485
# Patrick_Morin      2019-02-26     2018-06-21       1            4223         198
# Mitch_Slomiak      2019-02-26     2019-02-27       141          4637         0
# Matthew_Lewsadder  2019-02-25     2019-02-25       101          66450        6628
# Michael_Wilson     2019-02-23     2019-02-06       27           10908        1995
# Michael_Kahn       2019-02-23     2019-02-11       16           16308        2594
# Konrad_Thaler      2019-02-23     2019-02-27       78           38299        178
# Sanjeev_Balarajan  2019-02-23     2019-01-24       139          122123       2674
# Lee_Wheeler        2019-02-22     2019-02-25       78           55014        1858
# Jim_Knapp          2019-02-21     2019-02-21       150          3996         185
# David_Hohl         2019-02-20     2019-01-10       7            21326        2257
# Tony_Christopher   2019-02-20     2019-02-12       38           25173        2418
# Larry_Shanahan     2019-02-19     2018-12-19       1            2631         276
# John_Nadler        2019-02-19     2019-02-14       66           24489        2189
# Scott_StGermain    2019-02-18     2019-01-19       86           53189        869
# Peter_Johnson      2019-02-18     2019-02-18       3            646          356
# Keith_Britany      2019-02-18     2019-02-06       15           2248         255
# Laurence_Kuhn      2019-02-18     2019-02-18       108          11734        418
# Andrew_M_Webster   2019-02-17     2019-01-30       29           8336         905
# EO_Rojas           2019-02-17     2019-02-05       130          97338        4000
# David_Mock         2019-02-16     2019-02-17       5            2576         252
# Rick_Kananen       2019-02-16     2019-02-16       24           534          168
# Jim_Leney          2019-02-16     2018-04-13       24           6219         71
# Bob_Silver         2019-02-15     2018-08-23       2            768          0
# Steve_Fitzsimons   2019-02-15     2019-02-25       123          2679         73
# Antonio_Martinez   2019-02-15     2019-02-28       20           5678         505
# Michael_Skowronek  2019-02-15     2019-02-25       11           15623        216
# Joseph_Kuo         2019-02-14     2019-01-02       3            2595         885
# Michael_Orr        2019-02-14     2019-02-14       105          91616        8016
# Dave_Lloyd         2019-02-14     2019-02-11       25           10372        6351
# David_Montagna     2019-02-13     2019-02-28       7            8105         0
# Bruce_Scheer       2019-02-13     2019-02-13       4            5574         235
# Barry_Finkelstein  2019-02-12     2019-01-08       26           45727        1638
# Raymond_Miller     2019-02-12                      0            355          9
# Marco_Milletti     2019-02-11     2018-10-11       0            11372        309
# Chris_Edgar        2019-02-11     2018-11-12       0            68           41
# Juergen_Weltz      2019-02-10     2018-12-05       5            5186         199
# S_James_Biggs      2019-02-10     2019-02-14       47           13851        392
# John_Jeffs         2019-02-10                      0            319          301
# Roger_Chapman      2019-02-10     2019-02-10       11           1864         353
# Marton_Toth        2019-02-07     2019-02-07       0            91           91
# Ian_Wilkes         2019-02-06     2019-02-21       1            1460         1460
# David_Nickerson    2019-02-06     2018-11-13       2            4238         187
# Garry_Cheney       2019-02-05     2019-02-11       75           1472         324
# Chris_Reed         2019-02-05     2019-02-01       25           8296         1861
# Bo_Zhou            2019-02-04     2019-01-18       6            2569         1560
# Samyeer_Metrani    2019-02-03     2019-02-21       3            265          265
# Keerti_Narayan     2019-01-31     2019-01-31       2            188          188
# Bran_Scott         2019-01-28                      0            0            0
# Jerry_Raitzer      2019-01-27     2019-01-09       2            3396         2152
# Francis_daCosta    2019-01-24     2018-12-14       5            8695         511
# Don_Morgan         2019-01-23     2018-10-04       5            517          0
# Geoff_Wright       2019-01-20     2019-01-13       3            760          0
# Howard_Bailey      2019-01-18     2019-01-11       0            252          252
# Brad_Peppard       2019-01-15     2019-02-05       17           8675         752
# Vern_Mcgeorge      2019-01-13     2018-11-14       11           1898         0
# Sridhar_Ramanathan 2019-01-13     2019-01-12       26           11994        1201
# Flint_Thorne       2019-01-11     2019-01-09       13           3242         21
# Mark_Habberley     2019-01-10     2018-04-25       3            1021         0
# Clark_Zhang        2019-01-10     2019-01-10       20           5822         62
# Doug_Greig         2019-01-10     2019-01-10       29           9884         494
# Dave_Mahal         2019-01-09                      0            247          170
# Brian_Ruthruff     2019-01-09     2019-02-13       3            391          47
# William_Burton     2019-01-09     2019-02-14       22           1084         458
# Tonio_Schutze      2019-01-09                      0            351          17
# Ken_Krantz         2019-01-08     2018-10-19       0            819          457
# John_Thompson      2018-12-27     2018-11-26       91           94985        0
# Ron_Tugender       2018-12-20     2018-12-09       68           37760        0
# Gene_Sussli        2018-12-14     2019-02-09       28           13261        0
# Ron_McDowell       2018-11-20     2017-12-08       1            274          0
# Deven_Kalra        2018-10-31     2018-10-30       1            423          0
# Dave_Mussoff       2018-10-23     2018-10-23       19           12778        0
# Graham_Howe        2018-09-24                      0            80           0
# Narjit_Chadha      2018-09-19     2016-10-12       0            40           0
# Dave_Reid          2018-09-18                      0            20           0
# Tesh_Tesfaye       2018-09-13     2016-12-21       1            567          0
# Barry_Dobyns       2018-08-25     2018-02-08       2            2152         0
# Peter_Montana      2018-08-19     2018-08-18       19           6150         0
# Butch_Dority       2018-08-13                      0            1196         0
# Johan_Knall        2018-08-07     2018-10-11       1            2896         0
# John_Bodeau        2018-07-30     2019-02-18       41           3576         0
# Gary_Chan          2018-07-11     2017-11-10       4            4507         0
# Brad_Milliken      2018-06-26     2019-01-07       5            81           0
# Gary_Plep          2018-06-24     2019-02-14       2            1385         0
# Kevin_Shutta       2018-05-26     2018-03-18       1            776          0
# Curt_Haynes        2018-05-16     2018-05-02       17           3750         0
# Alan_Schoen        2018-04-23     2018-09-25       0            925          0
# Dennis_Sorensen    2018-04-13     2018-08-23       6            1644         0
# Shane_Reed         2018-04-08                      0            592          0
# Eamon_Rooney       2018-03-27                      0            250          0
# Tony_Pogue         2018-03-22     2018-03-13       0            0            0
# Peter_Sanchez      2018-03-21                      0            611          0
# Brad_Fino          2018-03-09     2018-01-08       16           4936         0
# Jim_LoConte        2018-02-18     2018-02-14       4            863          0
# Jack_Shannon       2018-02-18     2018-01-03       1            42           0
# Aaron_Jenkins      2018-02-05     2017-09-30       1            6581         0
# Glenn_Davis        2018-01-24     2016-12-14       0            230          0
# Ravi_Narra         2018-01-09     2017-12-31       11           7130         0
# Maarten_Korringa   2018-01-06     2017-01-20       1            3712         0
# Chris_Wilke        2018-01-05     2018-02-16       1            598          0
# Lars_Rider         2018-01-05     2019-01-18       154          7014         0
# Greg_Thayer        2017-12-30     2018-10-19       1            626          0
# Bill_Heller        2017-12-28     2019-02-07       9            1529         0
# John_Piggott       2017-12-22     2016-07-22       1            252          0
# Timothy_Plantikow  2017-12-21                      0            149          0
# Igor_Ukrainczyk    2017-12-08                      0            23           0
# Ken_Hartman        2017-11-29     2016-11-17       0            601          0
# Steve_Benjamin     2017-11-16     2016-11-26       0            857          0
# Toby_Ward          2017-11-02     2017-11-02       0            129          0
# How_Shaw           2017-09-13     2019-02-08       0            0            0
# Christian_Agardi   2017-08-18     2018-12-20       15           1736         0
# Al_Dorji           2017-08-09                      0            10           0
# Stephen_Gorman     2017-07-19     2017-04-11       2            2507         0
# Steve_Lang         2017-07-01     2017-06-12       41           35305        0
# Jerry_Bowes        2017-06-02     2016-12-30       7            4366         0
# Johnny_Alexander   2017-05-13     2017-08-05       1            6022         0
# Dennis_Adsit       2017-02-15     2018-10-10       0            611          0
# Praveen_Rangu      2017-01-30     2017-01-02       1            293          0
# Udy_Gold           2017-01-13     2017-01-20       12           1023         0
# Robert_Nelson      2017-01-03     2018-10-11       0            0            0
# Jason_Heimann      2016-12-26     2016-10-10       2            797          0
# Nicolas_Ardelean   2016-12-12                      0            2058         0
# Bill_Strahm        2016-11-24     2018-10-10       6            1562         0
# Mohamed_Abdelhay   2016-09-23     2016-09-23       2            668          0
# Louie_Ramos_jr     2016-09-15                      0            0            0
# Mike_Corner        2016-09-11                      0            0            0
# Barry_Samuel       2016-08-27                      0            170          0
# Chris_Nordlinger   2016-08-22                      0            136          0
# Sanford_Dietrich   2016-08-16                      0            102          0
# Bradley_Miles                     2019-02-05       0            0            0
# Matt_Hill                                          0            0            0
# MD_Admin                                           0            0            0
# Mike_Wilkins                                       0            0            0
#
# 0 users updated out of 195 possible targets out of 204 total users.