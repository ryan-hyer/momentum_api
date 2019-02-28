require '../utility/momentum_api'

@do_live_updates = false 
client = connect_to_instance('live')   # 'live' or 'local'

# testing variables
@target_username = 'Eric_Nitzberg'
@issue_users = %w() # debug issue user_names

@user_option_targets = {
    'email_private_messages': true, # Send me an email when someone messages me
    'email_direct': true,           # Send me an email when someone quotes me, replies to my post, mentions my @username, or invites me to a topic
    'email_always': true,           # Send me email notifications even when I am active on the site
    # 'email_digests': true         # When I don’t visit here, send me an email summary of popular topics and replies
}

@target_groups = %w(trust_level_0)
@exclude_user_names = %w(js_admin Winston_Churchill sl_admin JP_Admin admin_sscott RH_admin KM_Admin)
@field_settings = "%-18s %-24s %-14s %-14s %-14s %-14s\n"

@user_count, @matching_categories_count, @users_updated = 0, 0, 0, 0

def print_user_options(user_option)
  printf @field_settings, @users_username,
         user_option[@user_option_targets.keys[0].to_s], user_option[@user_option_targets.keys[1].to_s],
         user_option[@user_option_targets.keys[2].to_s], user_option[@user_option_targets.keys[3].to_s],
         user_option['mailing_list_mode']
end

# standardize_email_settings
def apply_function(client, user)         # TODO test mailing list mode, 1. last seen, Eric_Nitzberg, push to mother
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
      all_settings_true = [user_option[@user_option_targets.keys[0].to_s], user_option[@user_option_targets.keys[1].to_s],
              user_option[@user_option_targets.keys[2].to_s]].all?
      if all_settings_true
        # puts 'All settings are correct'
      else
        print_user_options(user_option)

        if @do_live_updates
          update_response = client.update_user(@users_username, @user_option_targets)
          puts update_response[:body]['success']
          @users_updated += 1

          # check if update happened
          user_option_after_update = client.user(@users_username)['user_option']
          print_user_options(user_option_after_update)
          sleep(1)
        end
      end
    end
    break
  end
end

printf @field_settings, 'UserName',
       @user_option_targets.keys[0], @user_option_targets.keys[1],
       @user_option_targets.keys[2], @user_option_targets.keys[3], 'mailing_list_mode'

apply_to_all_users(client)

puts "\n#{@users_updated} users updated out of #{@user_count} users found."


# Feb 27, 2019
#
# UserName           email_private_messages   email_direct   email_always                  mailing_list_mode
# Joe_Sabolefski     false                    false          false                         false
# OK
# Joe_Sabolefski     true                     true           true                          false
# John_Mansperger    true                     true           false                         false
# OK
# John_Mansperger    true                     true           true                          false
# Mark_Thorpe        true                     false          false                         false
# OK
# Mark_Thorpe        true                     true           true                          false
# Curt_Weil          true                     true           false                         true
# OK
# Curt_Weil          true                     true           true                          true
# Stefan_Schmitz     true                     true           false                         true
# OK
# Stefan_Schmitz     true                     true           true                          true
# John_Lasersohn     true                     true           false                         false
# OK
# John_Lasersohn     true                     true           true                          false
# Rich_Worthington   true                     true           false                         true
# OK
# Rich_Worthington   true                     true           true                          true
# Chris_Steck        true                     false          false                         false
# OK
# Chris_Steck        true                     true           true                          false
# Benjamin_Berman    true                     false          false                         false
# OK
# Benjamin_Berman    true                     true           true                          false
# Jeff_Cintas        true                     true           false                         true
# OK
# Jeff_Cintas        true                     true           true                          true
# Edmond_Cote        true                     true           false                         true
# OK
# Edmond_Cote        true                     true           true                          true
# Jack_McInerney     true                     false          false                         false
# OK
# Jack_McInerney     true                     true           true                          false
# Tom_Feasby         true                     true           false                         true
# OK
# Tom_Feasby         true                     true           true                          true
# Mitch_Slomiak      true                     true           false                         true
# OK
# Mitch_Slomiak      true                     true           true                          true
# Dan_Ollendorff     false                    false          false                         false
# OK
# Dan_Ollendorff     true                     true           true                          false
# Matthew_Lewsadder  true                     true           false                         false
# OK
# Matthew_Lewsadder  true                     true           true                          false
# Robbie_Bow         false                    false          false                         false
# OK
# Robbie_Bow         true                     true           true                          false
# Tony_Christopher   true                     true           false                         false
# OK
# Tony_Christopher   true                     true           true                          false
# Scott_StGermain    true                     true           false                         false
# OK
# Scott_StGermain    true                     true           true                          false
# Art_Muir           true                     true           false                         false
# OK
# Art_Muir           true                     true           true                          false
# EO_Rojas           true                     true           false                         false
# OK
# EO_Rojas           true                     true           true                          false
# Barry_Finkelstein  true                     false          false                         false
# OK
# Barry_Finkelstein  true                     true           true                          false
# John_Jeffs         true                     false          true                          false
# OK
# John_Jeffs         true                     true           true                          false
# Chris_Reed         true                     true           false                         false
# OK
# Chris_Reed         true                     true           true                          false
# Don_Morgan         true                     true           false                         false
# OK
# Don_Morgan         true                     true           true                          false
# Geoff_Wright       true                     true           false                         false
# OK
# Geoff_Wright       true                     true           true                          false
# Brad_Peppard       true                     true           false                         true
# OK
# Brad_Peppard       true                     true           true                          true
# Tonio_Schutze      false                    false          false                         false
# OK
# Tonio_Schutze      true                     true           true                          false
# Ken_Krantz         true                     false          false                         false
# OK
# Ken_Krantz         true                     true           true                          false
# Michael_Hayes      false                    false          false                         false
# OK
# Michael_Hayes      true                     true           true                          false
# Dave_Mussoff       true                     true           false                         false
# OK
# Dave_Mussoff       true                     true           true                          false
# Narjit_Chadha      false                    false          false                         false
# OK
# Narjit_Chadha      true                     true           true                          false
# Barry_Dobyns       true                     true           false                         false
# OK
# Barry_Dobyns       true                     true           true                          false
# Peter_Montana      false                    false          false                         false
# OK
# Peter_Montana      true                     true           true                          false
# Kevin_Shutta       false                    false          false                         false
# OK
# Kevin_Shutta       true                     true           true                          false
# Alan_Schoen        false                    false          false                         false
# OK
# Alan_Schoen        true                     true           true                          false
# Jim_LoConte        false                    false          false                         false
# OK
# Jim_LoConte        true                     true           true                          false
# Aaron_Jenkins      false                    false          false                         false
# OK
# Aaron_Jenkins      true                     true           true                          false
# Ravi_Narra         true                     true           false                         true
# OK
# Ravi_Narra         true                     true           true                          true
# Lars_Rider         true                     true           false                         true
# OK
# Lars_Rider         true                     true           true                          true
# Greg_Thayer        false                    false          false                         false
# OK
# Greg_Thayer        true                     true           true                          false
# John_Piggott       true                     true           false                         false
# OK
# John_Piggott       true                     true           true                          false
# Ken_Hartman        false                    false          false                         false
# OK
# Ken_Hartman        true                     true           true                          false
# Toby_Ward          false                    false          false                         false
# OK
# Toby_Ward          true                     true           true                          false
# Johnny_Alexander   false                    false          false                         false
# OK
# Johnny_Alexander   true                     true           true                          false
# Praveen_Rangu      true                     true           false                         false
# OK
# Praveen_Rangu      true                     true           true                          false
# Jason_Heimann      false                    false          false                         false
# OK
# Jason_Heimann      true                     true           true                          false
# Nicolas_Ardelean   false                    false          false                         false
# OK
# Nicolas_Ardelean   true                     true           true                          false
# Sanford_Dietrich   false                    false          false                         false
# OK
# Sanford_Dietrich   true                     true           true                          false
# Matt_Hill          false                    false          false                         false
# OK
# Matt_Hill          true                     true           true                          false
# Mike_Wilkins       true                     true           false                         false
# OK
# Mike_Wilkins       true                     true           true                          false
# 