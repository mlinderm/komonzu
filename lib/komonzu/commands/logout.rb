module Komonzu::Command
  class Logout < Base
    def index
      Komonzu::Command.run_internal "auth:delete_credentials", args.dup
      display "Local credentials cleared."
    end
	end
end 
