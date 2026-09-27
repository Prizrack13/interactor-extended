# frozen_string_literal: true

module Interactor
  module Validations
    class Required < Base
      def validate(value, _interactor)
        value.nil? ? false : nil
      end

      protected

      def default_message
        "#{param_label} is required"
      end
    end
  end
end
