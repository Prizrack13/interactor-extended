# frozen_string_literal: true

module Interactor
  module Duration
    # Formats duration data into a string.
    class StringFormatter < JsonFormatter
      # Returns the string representation of the duration data.
      # @return String
      def value
        super
        flat_data = to_flat(tree)

        if @options[:flat]
          max = flat_data.map { _1[:name].length }.max
          return flat_data.map { message(_1, max) }.join("\n")
        end

        max = flat_data.map { (_1[:level] * 2) + _1[:name].length }.max
        tree_value(tree, max).strip
      end

      protected

      def tree_value(node, max, prefix = '', is_last: true, connector: nil, new_prefix: nil) # rubocop:disable Metrics
        if node.is_a?(Array)
          return node.map.with_index do |child, i|
            tree_value(child, max, '', is_last: i == node.size - 1, connector: '', new_prefix: '')
          end.join
        end

        children = node[:children].to_a
        new_prefix ||= prefix + (is_last ? '  ' : '│ ')
        [
          prefix,
          connector || (is_last ? '└ ' : '├ '),
          message(node, max),
          "\n",
          children.map.with_index do |child, i|
            tree_value(child, max, new_prefix, is_last: i == children.size - 1)
          end.join
        ].join
      end

      def message(node, max)
        [
          node[:name].ljust(max - (@options[:flat] ? 0 : node[:level] * 2)),
          [
            "count: #{node[:count]}".ljust(10),
            "time: #{node[:time].to_s.ljust(25)}",
            "own: #{node[:own].to_s.ljust(25)}",
            "max: #{node[:max].to_s.ljust(25)}"
          ].join("\t")
        ].join("\t")
      end
    end
  end
end
