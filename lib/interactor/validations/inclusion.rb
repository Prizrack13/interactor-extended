# frozen_string_literal: true

module Interactor
  module Validations
    class Inclusion < Base
      def initialize(value, build_options)
        super
        @list = value.is_a?(Hash) ? value.fetch(:in) : value
      end

      def validate(value, _interactor)
        value.nil? || @list.include?(value) ? nil : false
      end

      protected

      def default_message
        "#{param_label} is not included in #{@list.inspect}"
      end
    end
  end
end
