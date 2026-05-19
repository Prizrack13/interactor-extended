# frozen_string_literal: true

module Interactor
  # Defines inputs and outputs for an interactor's context.
  module ContextDefinition
    include Interactor::Extended::Helpers

    class << self
      def included(base)
        base.extend(ClassMethods)
        base.remove_all_attributes!
      end
    end

    module ClassMethods
      attr_accessor :attributes

      # Defines an attribute for the context.
      # @param methods [Symbol, String] The attribute names.
      # @param array [bool] Whether the attribute is an array.
      # @param default [untyped, nil] Default value for the attribute.
      # @param required [bool] Whether the attribute is required.
      # @param direction [Symbol] The direction of the attribute (:input or :output).
      def attribute(*methods, array: false, default: nil, required: false, direction: :output) # rubocop:disable Metrics
        self.attributes ||= {}
        if !(methods.last.is_a?(String) || methods.last.is_a?(Symbol)) || methods.last == :boolean
          type = methods.pop
          type = [TrueClass, FalseClass] if type == :boolean
          type = type.is_a?(Array) ? type.map(&:name) : type.name
          methods.each do |method|
            attributes[method] = {
              type:,
              direction:,
              array:,
              default:,
              required:
            }
          end
        end
        methods.each do |method|
          define_method(method) { context[method] }
        end
        return if direction != :output

        methods.each do |method|
          define_method(:"#{method}=") { |value| set_attribute(method, value) }
        end
      end

      # Defines an input attribute.
      # @param methods [Symbol, String] The input names.
      # @param array [bool] Whether the input is an array.
      # @param default [untyped, nil] Default value.
      # @param required [bool] Whether the input is required.
      # @param writer [bool] Whether to define a writer method.
      def input(*methods, array: false, default: nil, required: false, writer: false)
        attribute(*methods, array:, default:, required:, direction: writer ? :output : :input)
      end

      # Defines an output attribute.
      # @param methods [Symbol, String] The output names.
      # @param array [bool] Whether the output is an array.
      # @param default [untyped, nil] Default value.
      # @param required [bool] Whether the output is required.
      def output(*methods, array: false, default: nil, required: false)
        attribute(*methods, array:, default:, required:)
      end

      # Returns all attributes defined in the class hierarchy.
      # @return [Hash[Symbol, Hash[Symbol, untyped]]]
      def all_attributes
        return @all_attributes if defined?(@all_attributes)

        klass = self
        attributes_arr = []
        loop do
          attributes_arr << klass.attributes
          klass = klass.superclass
          break if klass == Object
        end
        @all_attributes ||= attributes_arr.reverse.compact.each_with_object({}) { |attrs, result| result.merge!(attrs) }
      end

      # Removes all cached attributes.
      # @return [void]
      def remove_all_attributes!
        remove_instance_variable(:@all_attributes) if defined?(@all_attributes)
      end
    end

    def initialize(*)
      super
      initialize_default_values
      errors = check_attributes
      context.fail!(errors:, interactor: self.class.name) unless errors.empty?
    rescue Failure # rubocop:disable Lint/SuppressedException
    end

    # Runs the interactor, raising a Failure if the context has failed.
    # @return [untyped]
    def run!
      raise Failure, context if context.failure?

      super
    end

    private

    def initialize_default_values
      self.class.all_attributes
          .select { |key, options| !options[:default].nil? && !context.respond_to?(key) }
          .each do |key, options|
        value =
          if options[:default].is_a?(Proc)
            instance_exec(*[self, context][0, options[:default].arity], &options[:default])
          else
            deep_dup(options[:default])
          end
        set_attribute(key, value)
      end
    end

    def set_attribute(key, value)
      error = check_attribute(key, value)
      context.fail!(errors: { key => [error] }) if error
      context[key] = value
    end

    def check_attributes
      self.class.all_attributes.filter_map do |key, _options|
        error = check_attribute(key)
        [key, [error]] if error
      end.to_h
    end

    def check_attribute(key, value = nil) # rubocop:disable Metrics
      options = self.class.all_attributes[key]
      return unless options

      value ||= context[key]
      types = [options[:type]].flatten.map { safe_constantize(_1) }
      if value.nil?
        return options[:required] ? "#{options[:direction].capitalize} param \"#{key}\" is required" : nil
      end

      if options[:array]
        return if value.is_a?(Array) && value.all? { |item| types.any? { |type| item.is_a?(type) } }

        return "#{options[:direction].capitalize} param \"#{key}\" is not kind of Array of #{types.join(', ')}"
      end
      return if types.any? { |type| value.is_a?(type) }

      "#{options[:direction].capitalize} param \"#{key}\" is not kind of #{types.join(', ')}"
    end
  end
end
