# frozen_string_literal: true

module Interactor
  # Defines inputs and outputs for a light context interactor.
  module LightContextDefinition
    include Interactor::Extended::Helpers

    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      # Defines an attribute for the context.
      # @param methods [Symbol, String] The attribute names.
      # @param array [bool] Whether the attribute is an array.
      # @param default [untyped, nil] Default value.
      # @param required [bool] Whether the attribute is required.
      # @param direction [Symbol] The direction (:input or :output).
      def attribute(*methods, array: false, default: nil, required: false, direction: :output) # rubocop:disable Lint/UnusedMethodArgument
        methods.pop if !(methods.last.is_a?(String) || methods.last.is_a?(Symbol)) || methods.last == :boolean
        methods.each do |method|
          define_method(method) { context[method] }
        end
        return if direction != :output

        methods.each do |method|
          define_method(:"#{method}=") { context[method] = _1 }
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
    end
  end
end
