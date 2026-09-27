# frozen_string_literal: true

module Interactor
  # Type marker for boolean constraints. Accepts true and false values.
  # Use as `input :flag, Boolean` or `input :flag, type: Boolean`.
  module Boolean
    def self.===(other)
      [true, false].include?(other)
    end
  end
end
