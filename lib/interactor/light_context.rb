# frozen_string_literal: true

module Interactor
  # A lightweight context object for interactors.
  class LightContext < BasicObject
    %i[
      block_given?
      class
      hash
      instance_of?
      instance_variables
      is_a?
      kind_of?
      method
      methods
      nil?
      object_id
      private_methods
      public_send
      send
      tap
      then
      raise
      itself
    ].each do |method_name|
      define_method(method_name, ::Kernel.instance_method(method_name))
    end

    # Checks if the context is successful.
    # @return [bool]
    def success?
      !failure?
    end

    # Checks if the context has failed.
    # @return [bool]
    def failure?
      @failure || false
    end

    # Fails the context with the given data.
    # @param context [Hash] The failure data.
    # @raise [Failure] Always raises a Failure.
    def fail!(context = {})
      context.each { |key, value| self[key.to_sym] = value }
      @failure = true
      raise Failure, self
    end

    # Marks an interactor as called.
    # @param interactor [untyped] The interactor instance.
    def called!(interactor)
      _called << interactor
    end

    # Triggers rollback for all called interactors.
    # @return [bool]
    def rollback!
      return false if @rolled_back

      _called.reverse_each(&:rollback)
      @rolled_back = true
    end

    # Returns the list of interactors called so far (used for rollback).
    # @return [Array<untyped>]
    def _called
      @called ||= []
    end

    # Initializes the context with data.
    # @param data [Hash] The initial data.
    def initialize(data = {})
      @data = data.to_h.transform_keys(&:to_sym)
    end

    # Converts the context to a hash.
    # @return [Hash]
    def to_h
      data.to_h.clone
    end

    # Returns a string representation of the context.
    # @return [String]
    def inspect
      "#<#{self.class.name} #{to_h}>"
    end

    # Returns a string representation of the context.
    # @return [String]
    def to_s
      inspect
    end

    def pretty_print(pp)
      pp.text(inspect)
    end

    # Checks if the context contains a key.
    # @param name [untyped] The key to check.
    # @return [bool]
    def key?(name)
      data.key?(name.to_sym)
    end

    # Retrieves a value by key.
    # @param name [untyped] The key.
    # @return [untyped]
    def [](name)
      data[name.to_sym]
    end

    # Sets a value by key.
    # @param key [untyped] The key.
    # @param value [untyped] The value.
    # @return [untyped]
    def []=(key, value)
      data[key.to_sym] = value
    end

    # Checks if the context responds to a method.
    # @param name [untyped] The method name.
    # @param include_private [bool] Whether to include private methods.
    # @return [bool]
    def respond_to?(name, include_private = false) # rubocop:disable Style/OptionalBooleanParameter
      self.class.method_defined?(name) || respond_to_missing?(name, include_private)
    end

    # Deconstructs the context for pattern matching.
    # @param keys [Array<Symbol>, nil] The keys to include.
    # @return [Hash[Symbol, untyped]]
    def deconstruct_keys(keys = nil)
      deconstructed_keys = to_h.merge(success: success?, failure: failure?)
      keys ? deconstructed_keys.slice(*keys) : deconstructed_keys
    end

    private

    attr_reader :data

    def respond_to_missing?(name, _include_private = false)
      return true if name.end_with?('=')
      return true if name.end_with?('?') && data.key?(name.to_s.chomp('?').to_sym)
      return true if data.key?(name.to_sym)

      false
    end

    def method_missing(name, *args)
      if name.end_with?('?') && data.key?(key = name.to_s.chomp('?').to_sym)
        value = data[key]
        value.respond_to?(:empty?) ? !value.empty? : !!value # rubocop:disable Style/DoubleNegation
      elsif name.end_with?('=')
        data[name.to_s.chomp('=').to_sym] = args.first
      else
        data[name]
      end
    end

    class << self
      # Builds a LightContext from a hash or returns the context itself.
      # @param context [Hash, LightContext] The context data.
      # @return [LightContext]
      def build(context = {})
        context.is_a?(self) ? context : new(context.to_h)
      end
    end
  end
end
