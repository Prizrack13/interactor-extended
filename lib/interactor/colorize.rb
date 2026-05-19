# frozen_string_literal: true

module Interactor
  # Provides colorization utilities for strings.
  module Colorize
    class << self
      COLORS = {
        black: 30,
        red: 31,
        green: 32,
        yellow: 33,
        blue: 34,
        magenta: 35,
        cyan: 36,
        white: 37,
        default: 39,
        light_black: 90,
        light_red: 91,
        light_green: 92,
        light_yellow: 93,
        light_blue: 94,
        light_magenta: 95,
        light_cyan: 96,
        light_white: 97
      }.freeze
      MODES = {
        default: 0, # Turn off all attributes
        bold: 1,
        dim: 2,
        italic: 3,
        underline: 4,
        blink: 5,
        blink_slow: 5,
        blink_fast: 6,
        invert: 7,
        hide: 8,
        strike: 9,
        double_underline: 20,
        reveal: 28,
        overlined: 53
      }.freeze
      # Colorizes a string with the given options.
      # @param msg [String] The message to colorize.
      # @param color_value [Symbol, nil] The color value.
      # @param color [Symbol, nil] The color.
      # @param mode [Symbol, nil] The mode.
      # @param bg [Symbol, nil] The background color.
      # @return [String] The colorized string.
      def colorize(msg, color_value = nil, color: nil, mode: nil, bg: nil) # rubocop:disable Naming/MethodParameterName
        "\033[#{MODES[mode] || MODES[:bold]};#{COLORS[color_value || color] || COLORS[:default]};#{(COLORS[bg] || COLORS[:default]) + 10}m#{msg}\033[0m" # rubocop:disable Layout/LineLength
      end
    end

    # Colorizes the receiver using the Colorize module.
    # @param args [untyped] Arguments to pass to Colorize.colorize.
    # @return [String]
    def colorize(*)
      ::Interactor::Colorize.colorize(*)
    end
  end
end
