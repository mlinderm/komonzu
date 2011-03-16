module Komonzu::Command
  class Version < Base
    def index
      display Komonzu::Client.gem_version_string
    end
  end
end

