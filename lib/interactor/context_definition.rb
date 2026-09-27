# frozen_string_literal: true

module Interactor
  # Defines inputs and outputs for an interactor's context.
  module ContextDefinition
    include Interactor::Extended::Helpers

    # Non-validator options accepted by attribute/input/output.
    # Validator option keys are registered dynamically via Interactor::Validations.registry.
    NON_VALIDATOR_OPTIONS = %i[array coerce default direction writer validations].freeze

    class << self
      def included(base)
        base.extend(ClassMethods)
        base.remove_all_attributes!
      end

      def extract_options(args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        validate_options!(options)
        options[:type] ||= args.pop if positional_type?(args.last)
        options[:direction] ||= :output
        [args, options]
      end

      private

      def validate_options!(options)
        known = NON_VALIDATOR_OPTIONS | Interactor::Validations.registry.keys
        unknown = options.keys - known
        raise ArgumentError, "Unknown option(s): #{unknown.map(&:inspect).join(', ')}" if unknown.any?
      end

      def positional_type?(arg)
        return false unless arg
        return true if arg == :boolean

        !arg.is_a?(Symbol) && !arg.is_a?(String)
      end
    end

    module ClassMethods
      attr_accessor :attributes

      def attribute(*args)
        methods, options = ContextDefinition.extract_options(args)
        self.attributes ||= {}
        methods.each do |method|
          validations = Interactor::Validations.compile(options.merge(key: method))
          if validations.any? || !options[:default].nil? || options[:coerce]
            attributes[method] = options.slice(*%i[direction default coerce]).merge(validations:)
          end
          define_method(method) { context[method] }
          next if options[:direction] != :output

          define_method(:"#{method}=") { |value| set_attribute(method, value) }
        end
      end

      def input(*args)
        methods, options = ContextDefinition.extract_options(args)
        writer = options.delete(:writer)
        options[:direction] = writer ? :output : :input
        attribute(*methods, options)
      end

      def output(*args)
        methods, options = ContextDefinition.extract_options(args)
        options[:direction] = :output
        attribute(*methods, options)
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
        @all_attributes ||= attributes_arr.reverse.compact.each_with_object({}) do |attribute_set, merged|
          merged.merge!(attribute_set)
        end
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
      initialize_coerce_values
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
      self.class.all_attributes.each do |key, attribute_options|
        next if attribute_options[:default].nil? || context.respond_to?(key)

        value =
          if attribute_options[:default].is_a?(Proc)
            instance_exec(*[self, context].first(attribute_options[:default].arity), &attribute_options[:default])
          else
            deep_dup(attribute_options[:default])
          end
        set_attribute(key, value)
      end
    end

    def set_attribute(key, value)
      value = apply_coerce(self.class.all_attributes[key]&.[](:coerce), value) unless value.nil?
      errors = check_attribute(key, value)
      context.fail!(errors: { key => errors }) if errors.any?
      context[key] = value
    end

    def initialize_coerce_values
      self.class.all_attributes.each do |key, opts|
        next unless opts[:coerce] && !context[key].nil?

        context[key] = apply_coerce(opts[:coerce], context[key])
      end
    end

    def apply_coerce(coerce, value)
      case coerce
      when Symbol then value.public_send(coerce)
      when Proc then coerce.call(value)
      when Class then coerce.parse(value)
      else value
      end
    end

    def check_attributes
      self.class.all_attributes.filter_map do |key, _attribute_options|
        errors = check_attribute(key)
        [key, errors] if errors.any?
      end.to_h
    end

    def check_attribute(key, value = nil)
      attribute_options = self.class.all_attributes[key]
      return [] unless attribute_options

      value ||= context[key]
      attribute_options[:validations].filter_map do |validator|
        result = validator.validate(value, self)
        next nil if result.nil?

        result.is_a?(String) ? result : validator.message(self)
      end
    end
  end
end
