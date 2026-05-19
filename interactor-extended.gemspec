# frozen_string_literal: true

require_relative 'lib/interactor/extended/version'

Gem::Specification.new do |spec|
  spec.name = 'interactor-extended'
  spec.version = Interactor::Extended::VERSION
  spec.authors = ['Anatolii Varanytsia']
  spec.email = ['prizrack13@gmail.com']

  spec.summary = 'Interactor Extensions'
  spec.description = 'Interactor-extended provide a useful extensions for the Interactor gem.'
  spec.homepage = 'https://github.com/prizrack13/interactor-extended.git'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.2'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['github_repo'] = 'ssh://github.com/prizrack13/interactor-extended'
  spec.metadata['source_code_uri'] = 'https://github.com/prizrack13/interactor-extended'
  spec.metadata['changelog_uri'] = "#{spec.metadata['source_code_uri']}/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'interactor', '~> 3.2.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
