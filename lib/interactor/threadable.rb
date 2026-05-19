# frozen_string_literal: true

module Interactor
  # Provides a thread helper that propagates duration tracking context into new threads.
  module Threadable
    # Spawns a new thread that inherits the current duration tracking context.
    # @yield The block to execute in the new thread.
    # @return [Thread]
    def thread(&)
      Interactor::Extended.thread(&)
    end
  end
end
