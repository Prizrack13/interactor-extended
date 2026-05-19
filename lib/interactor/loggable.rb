# frozen_string_literal: true

module Interactor
  # Provides logging functionality for interactors.
  module Loggable
    class << self
      # Includes the logging functionality into a base class.
      # @param base [Class] The class to include the module into.
      def included(base)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      # Returns the logger from the configuration.
      # @return [untyped]
      def logger
        ::Interactor::Extended.configuration.logger
      end
    end

    # Returns the logger.
    # @return [untyped]
    def logger
      self.class.logger
    end
  end
end
