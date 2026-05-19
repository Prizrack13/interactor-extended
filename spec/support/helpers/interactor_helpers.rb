# frozen_string_literal: true

module InteractorHelpers
  def build_interactor(klass = Interactor::Operation, &block)
    Class.new.send(:include, klass).tap do |klass_instance|
      klass_instance.class_eval do
        def self.name
          'Anonymous::Interactor::Operation'
        end
      end
      klass_instance.class_eval(&block) if block
    end
  end

  def build_test_interactor(name, &block)
    build_interactor do
      around do |interactor|
        context[:steps] << :"around_before_#{name}"
        interactor.call
        context[:steps] << :"around_after_#{name}"
      end
      before { context[:steps] << :"before_#{name}" }
      after { context[:steps] << :"after_#{name}" }
      define_method(:call) { context[:steps] << :"call_#{name}" }
      define_method(:rollback) { context[:steps] << :"rollback_#{name}" }
      class_eval(&block) if block
    end
  end

  def build_organizer(options = {}, klass = Interactor::Flow, &block)
    Class.new.send(:include, klass).tap do |klass_instance|
      klass_instance.class_eval do
        def self.name
          'Anonymous::Interactor::Flow'
        end
      end
      klass_instance.organize(options[:organize]) if options[:organize]
      klass_instance.class_eval(&block) if block
    end
  end

  def build_test_organizer(name, options = {}, &block)
    build_organizer(options) do
      around do |interactor|
        context[:steps] << :"around_before_#{name}"
        interactor.call
        context[:steps] << :"around_after_#{name}"
      end
      before { context[:steps] << :"before_#{name}" }
      after { context[:steps] << :"after_#{name}" }
      define_method(:call) do
        context[:steps] << :"call_#{name}"
        super()
      end
      define_method(:rollback) { context[:steps] << :"rollback_#{name}" }
      class_eval(&block) if block
    end
  end
end
