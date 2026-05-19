# frozen_string_literal: true

module Interactor
  module Extended
    # Manages configuration for the Interactor Extended gem.
    class Configuration
      attr_accessor :logger,
                    :type, # ctx|light|legacy|all|all_debug
                    :duration_format, # json|string|color_string
                    :on_duration
      attr_reader :types

      # Initializes the configuration with default values.
      def initialize
        @logger = defined?(Rails) ? Rails.logger : ::Logger.new($stdout)
        @type = :all
        @duration_format = :color_string
        @on_duration = -> { @logger.debug("\n#{_1}") }
        @types = {}
        add_type!(:base)
        add_type!(:ctx, [::Interactor::Contextable])
        add_type!(:light, [
                    ::Interactor::LightContextDefinition,
                    ::Interactor::Populate,
                    ::Interactor::Organize,
                    ::Interactor::Threadable
                  ], :ctx)
        add_type!(:legacy, [
                    ::Interactor::ContextDefinition,
                    ::Interactor::Populate,
                    ::Interactor::Organize,
                    ::Interactor::Threadable,
                    ::Interactor::Jobify
                  ], :ctx)
        add_type!(:all, [::Interactor::Colorize, ::Interactor::Loggable], :legacy)
        add_type!(:all_debug, [::Interactor::Duration], :all)
      end

      # Adds a new type to the configuration.
      # @param type [Symbol] The name of the type.
      # @param modules [Array<Module>] The modules to include.
      # @param inherit [Symbol, nil] The type to inherit from.
      # @raise [RuntimeError] If the type already exists.
      def add_type!(type, modules = [], inherit = nil)
        raise 'Can\'t replace' if @types.key?(type.to_sym)

        @types[type.to_sym] = (inherit ? @types[inherit.to_sym].to_a : []) + modules
      end
    end
  end
end
