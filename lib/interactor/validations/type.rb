# frozen_string_literal: true

module Interactor
  module Validations
    class Type < Base
      def initialize(value, options)
        super
        raw = value.is_a?(Hash) ? value.fetch(:with) : value
        @array = options[:array] || false
        @types = [*raw].map { _1 == :boolean ? Interactor::Boolean : _1 }.map(&:name)
      end

      def validate(value, _interactor)
        return nil if value.nil?

        types = @types.map { safe_constantize(_1) }
        valid =
          if @array
            value.is_a?(Array) && value.all? { |item| types.any? { |klass| klass === item } } # rubocop:disable Style/CaseEquality
          else
            types.any? { _1 === value } # rubocop:disable Style/CaseEquality
          end
        valid ? nil : false
      end

      protected

      def default_message
        "#{param_label} is not kind of #{@array ? 'Array of ' : ''}#{@types.join(', ')}"
      end
    end
  end
end
