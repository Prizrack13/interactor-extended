# frozen_string_literal: true

module Interactor
  module Validations
    class Format < Base
      def initialize(value, options)
        super
        opts = value.is_a?(Hash) ? value : { with: value }
        @with = opts[:with]
        @without = opts[:without]
      end

      def validate(value, _interactor)
        return nil if value.nil?

        s = value.to_s
        return false if @with && !@with.match?(s)
        return false if @without&.match?(s)

        nil
      end
    end
  end
end
