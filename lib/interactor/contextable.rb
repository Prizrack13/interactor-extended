# frozen_string_literal: true

module Interactor
  # Provides context management for interactors.
  module Contextable
    # Initializes the contextable with a context hash.
    # @param context [Hash] The context data.
    def initialize(context = {})
      @context = LightContext.build(context)
    end

    # Returns the context object.
    # @return [LightContext]
    def ctx
      @context
    end
  end
end
