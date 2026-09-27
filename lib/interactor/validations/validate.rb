# frozen_string_literal: true

module Interactor
  module Validations
    class Validate < Base
      def initialize(value, build_options)
        super
        @validator = value.is_a?(Hash) ? value.fetch(:with) : value
      end

      def validate(value, interactor)
        return nil if value.nil?
        return coerce_symbol_result(interactor.send(@validator)) if @validator.is_a?(Symbol)

        coerce_proc_result(interactor.instance_exec(*[value].first(@validator.arity.abs), &@validator))
      end

      private

      def coerce_symbol_result(result)
        return result if result.is_a?(String)

        (result ? nil : false)
      end

      def coerce_proc_result(result)
        return result if result.is_a?(String)

        (result == false ? false : nil)
      end
    end
  end
end
