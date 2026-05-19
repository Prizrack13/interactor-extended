# frozen_string_literal: true

module Interactor
  module Duration
    # Formats duration data into a colorized string.
    class ColorStringFormatter < StringFormatter
      protected

      def message(node, max)
        [
          ::Interactor::Colorize.colorize(node[:name].ljust(max - (node[:level] * 2)), :yellow),
          [
            "count: #{node[:count]}".ljust(10),
            "time: #{::Interactor::Colorize.colorize(node[:time].to_s.ljust(25), :green)}",
            "own: #{::Interactor::Colorize.colorize(node[:own].to_s.ljust(25), :green)}",
            "max: #{::Interactor::Colorize.colorize(node[:max].to_s.ljust(25), :green)}"
          ].join("\t")
        ].join("\t")
      end
    end
  end
end
