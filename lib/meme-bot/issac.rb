require 'isaac/bot'

module Isaac
  class Queue
    private
    def exceed_limit?
      # now work with all irc server
      transfered_after_next_send > 1000
    end
  end
end
