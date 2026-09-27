# frozen_string_literal: true

module Interactor
  module Validations
    class Length < Base
      def initialize(value, options)
        super
        opts = value.is_a?(Hash) ? value : { minimum: value }
        range = opts[:in]
        @is = opts[:is]
        @minimum = opts[:minimum] || (range.respond_to?(:min) ? range.min : nil)
        @maximum = opts[:maximum] || (range.respond_to?(:max) ? range.max : nil)
      end

      def validate(value, _interactor) # rubocop:disable Metrics/CyclomaticComplexity
        return if value.nil?

        len = value.length
        return false if @is && len != @is
        return false if @minimum && len < @minimum
        return false if @maximum && len > @maximum

        nil
      end

      protected

      def default_message
        if @is
          "#{param_label} is the wrong length (should be #{@is})"
        elsif @minimum && @maximum
          "#{param_label} length must be between #{@minimum} and #{@maximum}"
        elsif @minimum
          "#{param_label} is too short (minimum is #{@minimum})"
        else
          "#{param_label} is too long (maximum is #{@maximum})"
        end
      end
    end
  end
end
