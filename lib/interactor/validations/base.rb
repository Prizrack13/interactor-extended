# frozen_string_literal: true

module Interactor
  module Validations
    @registry = {}

    class << self
      def register(key, klass)
        @registry[key] = klass
      end

      def unregister(klass)
        @registry.reject! { |_, v| v == klass }
      end

      attr_reader :registry

      def compile(opts)
        options = {
          key: opts[:key],
          direction: opts.fetch(:direction, :output),
          array: opts.fetch(:array, false)
        }
        [
          *opts.slice(*@registry.keys).map { |key, value| { key => value } },
          *opts[:validations]
        ].flat_map { compile_entry(_1, options) }
      end

      private

      def compile_entry(entry, options)
        return [entry.new(nil, options)] if entry.is_a?(Class)
        return [Interactor::Validations::Validate.new(entry, options)] unless entry.is_a?(Hash)

        compile_hash_entry(entry, options)
      end

      def compile_hash_entry(entry, options)
        msg_options = entry[:message] ? options.merge(message: entry[:message]) : options
        return [entry[:with].new(nil, msg_options)] if entry[:with].is_a?(Class)

        entry.filter_map { |key, value| @registry[key]&.new(value, msg_options) if value }
      end
    end

    # Base class for all validators.
    #
    # Subclasses auto-register by class name convention (Required → :required).
    # Call register_as :key to override the derived key.
    #
    # validate contract:
    #   nil    → valid
    #   false  → invalid; message is used for the error string
    #   String → invalid; used directly as the error message
    class Base
      include Interactor::Extended::Helpers

      def initialize(value, options = {})
        @key = options[:key]
        @direction = options[:direction]
        @message = (value.is_a?(Hash) ? value[:message] : nil) || options[:message]
      end

      def validate(_value, _interactor)
        raise NotImplementedError, "#{self.class.name}#validate is not implemented"
      end

      def message(interactor)
        (@message || default_message).then { _1.is_a?(Proc) ? interactor.instance_exec(&_1) : _1 }
      end

      protected

      def param_label
        "#{@direction.capitalize} param \"#{@key}\""
      end

      def default_message
        "#{param_label} is invalid"
      end

      class << self
        def inherited(subclass)
          super
          key = subclass.name&.split('::')&.last&.then do |name|
            name
              .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
              .gsub(/([a-z\d])([A-Z])/, '\1_\2')
              .downcase
              .to_sym
          end
          Interactor::Validations.register(key, subclass) if key
        end

        def register_as(key)
          Interactor::Validations.unregister(self)
          Interactor::Validations.register(key, self)
        end
      end
    end
  end
end
