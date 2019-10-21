
module MomentumApi
  class Man

    attr_reader :discourse, :user_client, :user_details, :users_categories
    attr_accessor :is_owner

    def initialize(discourse, user_client, user_details, mock: nil)
      raise ArgumentError, 'user_client needs to be defined' if user_client.nil?
      raise ArgumentError, 'user_details needs to be defined' if user_details.nil? || user_details.empty?

      @discourse          =   discourse
      @mock               =   mock

      @user_details       =   user_details
      @user_client        =   user_client

      begin
        @users_categories = @user_client.categories
        @mock ? sleep(0) : sleep(2) # Jul 25, 2019 set to 2 due to RateLimiter::LimitExceeded seen in D console emails
      rescue DiscourseApi::UnauthenticatedError
        @users_categories = nil
        # @discourse.options[:logger].warn "#{user_details['username']} : DiscourseApi::UnauthenticatedError - Not permitted to view resource."
      rescue DiscourseApi::TooManyRequests
        @discourse.options[:logger].warn 'Sleeping for 20 seconds ....'
        @mock ? sleep(0) : sleep(20)
        @users_categories = @user_client.categories
      end

      @is_owner = false

    end


    def run

      if @discourse.options[:issue_users].include?(@user_details['username'])
        puts "#{@user_details['username']} in scan_contexts"
      end

      # Examine Users Groups and Cagegories
      @user_details['groups'].each do |group|
        
        if @discourse.options[:issue_users].include?(@user_details['username'])
          puts "\n#{@user_details['username']}  with group: #{group['name']}\n"
        end

        # Group Cases
        @discourse.schedule.group_cases(self, group)

        # Category Cases
        if @users_categories and @discourse.schedule.options[:category]
          @discourse.schedule.category_cases(self, group:group)
        else
          # puts "\nSkipping Category Cases for #{@user_details['username']}.\n"
        end

      end

      # Once per User Cases
      @discourse.schedule.user_cases(self)

    end


    def print_user_options(user_details, fields: nil, user_label: 'UserName', user_field: nil,
                           nested_user_field: nil, hash: {'': nil})

      fields = fields ||  %w(last_seen_at last_posted_at post_count time_read recent_time_read)
      
      if nested_user_field
        nested_user_value = user_details
        nested_user_field.each {|level| nested_user_value = nested_user_value[level]}
      else
        nested_user_value = nil
        nested_user_field = ''
      end

      header = [user_label, fields[0], fields[1], fields[2], fields[3], fields[4], user_field, nested_user_field, hash.keys[0]]
                        # fields[3], fields[4], fields[5], nested_user_field
      field_settings = ""
      header.each do |head|
        head = head || ''
        field_settings <<  "%-#{head.length + 2}s "
      end
      heading = sprintf field_settings, *header

      body = sprintf field_settings, user_details['username'],
                     user_details[fields[0].to_s].to_s[0..9], user_details[fields[1].to_s].to_s[0..9],
                     user_details[fields[2].to_s], user_details[fields[3].to_s], user_details[fields[4].to_s],
                     user_details[user_field], nested_user_value, hash.values[0]

      @discourse.options[:logger].info heading
      @discourse.options[:logger].info body

    end

  end
end
