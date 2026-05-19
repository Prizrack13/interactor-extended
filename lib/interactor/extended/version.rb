# frozen_string_literal: true

module Interactor
  module Extended
    # The version string for the gem.
    VERSION =
      if File.exist?(File.expand_path(File.join(__dir__, '../../../VERSION')))
        File.read(File.expand_path(File.join(__dir__, '../../../VERSION')))
      else
        ''
      end.strip.freeze

    class << self
      # Returns the full version string including revision.
      # @return [String]
      def version
        [VERSION, revision].compact.join('-')
      end

      # Returns the git revision if available.
      # @return [String, nil]
      def revision
        source = Gem::Specification.find_by_name('interactor-extended')&.source
        source.revision if source.is_a?(Bundler::Source::Git)
      rescue Gem::MissingSpecError
        nil
      end
    end
  end
end
