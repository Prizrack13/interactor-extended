# frozen_string_literal: true

module Interactor
  module Validations
    class Presence < Base
      def validate(value, _interactor)
        blank?(value) ? false : nil
      end

      protected

      def default_message
        "#{param_label} can't be blank"
      end

      private

      def blank?(value)
        return true if value.nil?
        return value.strip.empty? if value.is_a?(String)
        return value.empty? if value.respond_to?(:empty?)

        false
      end
    end
  end
end
