# frozen_string_literal: true

module Interactor
  module Duration
    # Formats duration data into a JSON-compatible array of hashes.
    class JsonFormatter < BaseFormatter
      def value
        tree.then { @options[:flat] ? to_flat(_1) : _1 }
      end

      protected

      def tree
        @tree ||= process_duration(@duration.then { @options[:flat] ? process_flat_duration(_1) : _1 })
      end

      def process_duration(data, level = 0)
        data.group_by(&:first).map do |name, values|
          {
            name:,
            level:,
            count: values.count,
            time: values.sum { _1[3] - _1[2] }.fdiv(values.count),
            own: values.sum { _1[4] }.fdiv(values.count),
            max: values.max_by { _1[4] }.last,
            children: process_duration(values.flat_map { _1[1] }, level + 1)
          }
        end
      end

      def process_flat_duration(data)
        data.flat_map { [_1.dup.tap { |value| value[1] = [] }] + process_flat_duration(_1[1]) }
      end

      def to_flat(data)
        data.each_with_object([]) do |item, result|
          result << item.except(:children)
          result.concat(to_flat(item[:children]))
        end
      end
    end
  end
end
