# frozen_string_literal: true

module Interactor
  # Provides orchestration functionality for interactors.
  module Organize
    # A thread runner that executes a klass in a new thread.
    class ThreadRunner < Proc
      alias call! call
    end

    class << self
      # Includes the organize functionality into a base class.
      # @param base [Class] The class to include the module into.
      def included(base)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      # Creates a ThreadRunner for the given class.
      # @param klass [Class] The class to run in a thread.
      # @return [ThreadRunner]
      def thread(klass)
        ThreadRunner.new { |context| ::Interactor::Extended.thread { klass.call!(context) } }
      end
    end

    # Executes the organized interactors.
    # @return [untyped]
    def call
      organize(organized) if self.class.respond_to?(:organized)
    end

    protected

    # Organizes the execution of interactors.
    # @param organized [untyped] The interactors to organize.
    # @return [untyped]
    def organize(*organized)
      organized.flatten.map { _1.call!(context) }.map { _1.join if _1.is_a?(Thread) }
    end

    # Returns the organized interactors.
    # @return [untyped]
    def organized
      context[:organized] || self.class.organized
    end
  end
end
