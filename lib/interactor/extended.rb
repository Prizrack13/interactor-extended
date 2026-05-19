# frozen_string_literal: true

require 'interactor'
require 'logger'
require_relative 'extended/version'
require_relative 'extended/helpers'
require_relative 'extended/configuration'
require_relative 'contextable'
require_relative 'light_context'
require_relative 'light_context_definition'
require_relative 'context_definition'
require_relative 'organize'
require_relative 'populate'
require_relative 'loggable'
require_relative 'threadable'
require_relative 'duration/base_formatter'
require_relative 'duration/json_formatter'
require_relative 'duration/string_formatter'
require_relative 'duration/color_string_formatter'
require_relative 'duration'
require_relative 'jobify'
require_relative 'colorize'
require_relative 'flow'
require_relative 'operation'

module Interactor
  module Extended
    @cache = {}
    class << self
      # Returns the current configuration.
      # @return [Configuration]
      def configuration
        @configuration ||= Configuration.new
      end

      # Sets the configuration.
      # @param config [Configuration] The new configuration.
      # @return [Configuration]
      attr_writer :configuration

      # Yields the configuration for customization.
      # @yield [Configuration] The configuration object.
      # @return [untyped]
      def configure
        yield configuration
      end

      # Returns the modules to include for a given kind and type.
      # @param kind [Symbol] The kind of module (:flow or :operation).
      # @param type [Symbol, Array<Symbol>] The type or types of modules.
      # @return [Array<Module>]
      def modules(kind, type)
        [
          kind == :flow ? ::Interactor::Organizer : ::Interactor,
          *(type.is_a?(Array) ? type : configuration.types[type].to_a)
        ]
      end

      # Builds a module containing the specified kinds and types.
      # @param kind [Symbol] The kind of module.
      # @param type [Symbol, Array<Symbol>] The type or types of modules.
      # @return [Module]
      def build_module(kind, type)
        modules = modules(kind, type)
        @cache[[kind, type]] ||= Module.new do
          define_singleton_method(:included) do |base|
            modules.each { base.include(_1) }
          end
        end
      end

      # Spawns a new thread that inherits the current duration tracking context.
      # @yield The block to execute in the new thread.
      # @return [Thread]
      def thread(&block)
        current = Thread.current.thread_variable_get('interactor.duration')&.data
        Thread.new do
          Thread.current.thread_variable_set('interactor.duration_current', current)
          block.call
        end
      end
    end
  end
end
