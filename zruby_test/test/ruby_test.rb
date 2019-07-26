require 'pp'
require 'pry'

# contact_list = [
#     {"name" => "Jason", "phone_number" => "123"},
#     {"name" => "Nick", "phone_number" => "456"}
# ]

# contact_list.each do |contact|
#   puts "Contact: #{contact["name"]} and Phone Number: #{contact["phone_number"]}"
# end

# contact_list = {"name": true , "phone_number": false }
# months = Hash.new( "month" )
# months.name = 'month'
# puts months

# puts Dir.pwd

user_scores = {'User Scores': ''}
user_scores[:'email_always'] = true

user_messages = {'Messages': ''}
user_messages[:'message sent'] = false

scores = []
scores << user_scores
scores << user_messages


# user_option_targets = ['email_always': true,
# }
# user_option_targets = {
#     'email_always': true,
#     'email_direct': true,
#     'email_private_messages': true,
#     'email_digests': true
# }

# puts user_option_targets.keys[0]
# puts user_option_targets.values[0]
# puts contact_list.keys[0]
# printf "%-20s %-20s\n", '1', '2'
# puts user_option_targets.values.all?

# key_test = user_option_targets.keys[0]
# puts key_test
# puts user_option_targets[:key_test] #

# pp user_option_targets
# Pry::ColorPrinter.pp(user_option_targets)

field_settings = "%-35s %-20s \n"
# printf field_settings, 'User Scores', ''
scores.each do |score|
  score.each do |key, value|
    printf field_settings, key.to_s, value
  end
end
