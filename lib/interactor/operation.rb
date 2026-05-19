# frozen_string_literal: true

module Interactor
  # Provides operation management for interactors.
  module Operation
    class << self
      # Includes the operation modules into a base class.
      # @param base [Class] The class to include the module into.
      def included(base)
        Extended.modules(:operation, ::Interactor::Extended.configuration.type).each { base.include(_1) }
      end

      # Builds an operation module for the given type.
      # @param type [Symbol] The type of operation.
      # @return [Module]
      def [](type)
        Extended.build_module(:operation, type)
      end
    end
  end
end
