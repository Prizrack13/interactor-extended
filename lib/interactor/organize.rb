# frozen_string_literal: true

module Interactor
  module Organize
    class Step
      def initialize(hash)
        @klass = hash[:class]
        @if = hash[:if]
        @unless = hash[:unless]
        @thread = hash.fetch(:thread, false)
      end

      def call(interactor)
        return if @if && !guard(@if, interactor)
        return if @unless && guard(@unless, interactor)

        @thread ? ::Interactor::Extended.thread { invoke(interactor) } : invoke(interactor)
      end

      private

      def guard(cond, interactor)
        cond.is_a?(Symbol) ? interactor.send(cond) : interactor.instance_exec(&cond)
      end

      def invoke(interactor)
        return interactor.send(@klass) if @klass.is_a?(Symbol)

        method = @klass.respond_to?(:call!) ? :call! : :call
        @klass.public_send(method, interactor.context)
      end

      class << self
        def compile(entries)
          pair_merge(entries).map { compile_entry(_1) }
        end

        def compile_entry(entry)
          hash = entry.is_a?(Hash) ? entry : { class: entry }
          return new(hash) if hash[:if] || hash[:unless] || hash[:thread]

          klass = hash[:class]
          return ->(i) { i.send(klass) } if klass.is_a?(Symbol)

          m = klass.respond_to?(:call!) ? :call! : :call
          ->(i) { klass.public_send(m, i.context) }
        end

        private

        def pair_merge(entries)
          entries.each_with_object([]) do |entry, result|
            result <<
              if entry.is_a?(Hash) && !entry.key?(:class) && result.last && !result.last.is_a?(Hash)
                { class: result.pop }.merge(entry)
              else
                entry
              end
          end
        end
      end
    end

    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      def organized
        return @organized if instance_variable_defined?(:@organized)

        superclass.respond_to?(:organized) ? superclass.organized : []
      end

      def organize(*args)
        @organized = Step.compile(args.flatten)
      end

      def step(klass, **options)
        { class: klass }.merge(options)
      end

      def thread(klass, **)
        step(klass, thread: true, **)
      end
    end

    def call
      organize(organized)
    end

    protected

    def organize(*organized)
      organized.flatten.filter_map { _1.call(self) }.each { _1.join if _1.is_a?(Thread) }
    end

    def organized
      context[:organized] ? Step.compile(context[:organized]) : self.class.organized
    end
  end
end
