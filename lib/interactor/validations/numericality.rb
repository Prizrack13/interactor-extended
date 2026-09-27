# frozen_string_literal: true

module Interactor
  module Validations
    class Numericality < Base
      COMPARISONS = {
        equal_to: [:==, 'equal to'],
        other_than: [:!=, 'other than'],
        greater_than: [:>, 'greater than'],
        greater_than_or_equal_to: [:>=, 'greater than or equal to'],
        less_than: [:<, 'less than'],
        less_than_or_equal_to: [:<=, 'less than or equal to']
      }.freeze

      def initialize(value, options)
        super
        opts = value.is_a?(Hash) ? value : {}
        @only_integer = opts.fetch(:only_integer, false)
        @odd = opts.fetch(:odd, false)
        @even = opts.fetch(:even, false)
        @checks = COMPARISONS.filter_map { |k, (op, label)| [op, opts[k], label] if opts.key?(k) }
      end

      def validate(value, _interactor) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        return nil if value.nil?

        num = parse(value)
        return false if num.nil?
        return false if @only_integer && !num.is_a?(Integer)
        return false if @odd && num.even?
        return false if @even && num.odd?

        @checks.each { |op, expected, _| return false unless num.public_send(op, expected) }
        nil
      end

      protected

      def default_message
        parts = []
        parts << 'must be an integer' if @only_integer
        parts << 'must be odd' if @odd
        parts << 'must be even' if @even
        @checks.each { |_, val, label| parts << "must be #{label} #{val}" }
        "#{param_label} #{parts.empty? ? 'is not a number' : parts.join(', ')}"
      end

      private

      def parse(value)
        return value if value.is_a?(Numeric)
        return nil unless value.is_a?(String)

        Integer(value, exception: false) || Float(value, exception: false)
      end
    end
  end
end
