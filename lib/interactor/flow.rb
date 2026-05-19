# frozen_string_literal: true

module Interactor
  # Provides flow management for interactors.
  module Flow
    class << self
      # Includes the flow modules into a base class.
      # @param base [Class] The class to include the module into.
      def included(base)
        Extended.modules(:flow, ::Interactor::Extended.configuration.type).each { base.include(_1) }
      end

      # Builds a flow module for the given type.
      # @param type [Symbol] The type of flow.
      # @return [Module]
      def [](type)
        Extended.build_module(:flow, type)
      end
    end
  end
end
