# frozen_string_literal: true

module Interactor
  module Validations
    class Exclusion < Inclusion
      def validate(value, _interactor)
        !value.nil? && @list.include?(value) ? false : nil
      end

      protected

      def default_message
        "#{param_label} is excluded"
      end
    end
  end
end
