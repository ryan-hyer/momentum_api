# contact_list = [
#     {"name" => "Jason", "phone_number" => "123"},
#     {"name" => "Nick", "phone_number" => "456"}
# ]

# contact_list.each do |contact|
#   puts "Contact: #{contact["name"]} and Phone Number: #{contact["phone_number"]}"
# end

# contact_list = {"name": true , "phone_number": false }

user_option_targets = {
    'email_always': true,
    'email_direct': true,
    'email_private_messages': true,
    'email_digests': true
}

# puts user_option_targets.keys[0]
# puts user_option_targets.values[0]
# puts contact_list.keys[0]
# printf "%-20s %-20s\n", '1', '2'
# puts user_option_targets.values.all?

key_test = user_option_targets.keys[0]
puts key_test
puts user_option_targets[:key_test]