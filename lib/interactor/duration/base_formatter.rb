# frozen_string_literal: true

module Interactor
  module Duration
    # Base class for duration formatters.
    class BaseFormatter
      # Initializes the formatter with duration data.
      # @param duration Array[String, Array[Float, Float]] The duration data.
      def initialize(duration, options = {})
        @duration = duration
        @options = options
      end

      # Returns the duration data.
      # @return Array[String, Array[Float, Float]]
      def value
        @duration
      end

      class << self
        def value(data)
          format = ::Interactor::Extended.configuration.duration_format&.to_sym
          case format
          when :json, :flat_json then JsonFormatter
          when :string, :flat_string then StringFormatter
          else ColorStringFormatter
          end.new(data, flat: format.to_s.match(/^flat_/)).value
        end
      end
    end
  end
end
