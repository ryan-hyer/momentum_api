module MomentumApi
  class Man

    attr_reader :user_client, :user_details, :users_categories

    def initialize(user_client, user_details, users_categories=nil)
      raise ArgumentError, 'user_client needs to be defined' if user_client.nil?
      raise ArgumentError, 'user_details needs to be defined' if user_details.nil? || user_details.empty?

      @user_client        =   user_client
      @user_details       =   user_details
      @users_categories   =   users_categories
      
    end
  end
end
