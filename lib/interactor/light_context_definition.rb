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
      def attribute(*args)
        methods, options = Interactor::ContextDefinition.extract_options(args)
        methods.each { |method| define_method(method) { context[method] } }
        return if options[:direction] != :output

        methods.each { |method| define_method(:"#{method}=") { context[method] = _1 } }
      end

      def input(*args)
        methods, options = Interactor::ContextDefinition.extract_options(args)
        writer = options.delete(:writer)
        options[:direction] = writer ? :output : :input
        attribute(*methods, options)
      end

      def output(*args)
        methods, options = Interactor::ContextDefinition.extract_options(args)
        options[:direction] = :output
        attribute(*methods, options)
      end
    end
  end
end
