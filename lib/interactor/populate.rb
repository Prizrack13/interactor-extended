# frozen_string_literal: true

module Interactor
  # Provides context population functionality.
  module Populate
    class << self
      # Includes the populate functionality into a base class.
      # @param base [Class] The class to include the module into.
      def included(base)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      # Calls the interactor with the given arguments.
      # @param args [untyped] The arguments.
      # @return [untyped]
      def call(*args)
        populate(*args) { super(_1) }
      end

      # Calls the interactor with the given arguments, raising on failure.
      # @param args [untyped] The arguments.
      # @return [untyped]
      def call!(*args)
        populate(*args) { super(_1) }
      end

      private

      # Populates the context with data from the parent context.
      # @param context [Hash] The context to populate.
      # @param parent_context [untyped] The parent context.
      # @param keys [untyped] The keys to populate.
      # @yield [context] The context to yield.
      # @return [untyped]
      def populate(context = {}, parent_context = nil, *keys) # rubocop:disable Metrics
        parent_context = context[:context] if context[:context]
        keys = context[:context_keys] if context[:context_keys]
        return unless block_given?
        return yield(context) if parent_context.nil?

        original_keys = keys
        keys = parent_context.to_h.keys.grep(/^_/) if original_keys.empty?
        keys&.each { context[_1] = parent_context[_1] }
        yield(context).tap do |result|
          keys = result.to_h.keys.grep(/^_/) if original_keys.empty?
          keys.each { parent_context[_1] = result[_1] }
        end
      end
    end

    protected

    # Assigns data to the context.
    # @param data [Hash] The data to assign.
    # @return [LightContext]
    def context_assign(data = {})
      data.each { |key, value| context[key] = value }
      context
    end
  end
end
