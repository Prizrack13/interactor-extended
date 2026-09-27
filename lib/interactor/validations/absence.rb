# frozen_string_literal: true

module Interactor
  module Validations
    class Absence < Presence
      def validate(value, _interactor)
        blank?(value) ? nil : false
      end

      protected

      def default_message
        "#{param_label} must be blank"
      end
    end
  end
end
