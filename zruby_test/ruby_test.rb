contact_list = [
    {"name" => "Jason", "phone_number" => "123"},
    {"name" => "Nick", "phone_number" => "456"}
]

contact_list.each do |contact|
  puts "Contact: #{contact["name"]} and Phone Number: #{contact["phone_number"]}"
end