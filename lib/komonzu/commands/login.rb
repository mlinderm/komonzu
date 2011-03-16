module Komonzu::Command
  class Login < Base
    def index
      Komonzu::Command.run_internal "auth:reauthorize", args.dup
    end
	end
end 
