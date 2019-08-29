require 'csv'

path = "/Users/kimardenmiller/Dropbox/l_Spiritual/Momentum/Central/Discourse/Membership/Memberful_20190828e_members_export.csv"
lookup_table = CSV.read(path, headers: true)

# puts lookup_table[0]["Full Name"]

lookup_table.each do |row|
  puts row['Email']
  # puts row[0], row[1], row[3]
end