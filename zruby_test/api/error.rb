module MomentumAPI
  class MomentumError < StandardError
    attr_reader :response

    def initialize(message, response = nil)
      super(message)
      @response = response
    end
  end

  class Error < MomentumError
    attr_reader :wrapped_exception

    # Initializes a new Error object
    #
    # @param exception [Exception, String]
    # @return [MomentumApi::Error]
    def initialize(exception=$!)
      @wrapped_exception = exception
      exception.respond_to?(:message) ? super(exception.message) : super(exception.to_s)
    end
  end

  class UnauthenticatedError < MomentumError
  end

  class NotFoundError < MomentumError
  end

  class UnprocessableEntity < MomentumError
  end

  class TooManyRequests < MomentumError
  end
end
