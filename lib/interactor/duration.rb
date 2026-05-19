# frozen_string_literal: true

module Interactor
  # Provides duration tracking for interactors.
  module Duration
    Storage = Struct.new(:data, :total)
    class << self
      # Includes the duration tracking functionality into a base class.
      # @param base [Class] The class to include the module into.
      def included(base)
        base.extend(ClassMethods)
        base.class_eval do # rubocop:disable Metrics/BlockLength
          around :_process_duration

          def self.inherited(subclass)
            super
            subclass.around :_process_duration
          end

          private

          def _duration
            Thread.current.thread_variable_get('interactor.duration')
          end

          def _duration=(value)
            Thread.current.thread_variable_set('interactor.duration', value)
          end

          def _duration_current
            Thread.current.thread_variable_get('interactor.duration_current')
          end

          def _duration_current=(value)
            Thread.current.thread_variable_set('interactor.duration_current', value)
          end

          def _duration_clock
            Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
          end

          def _process_duration(interactor, key = self.class.name)
            self._duration ||= nil
            initial_operation = _duration.nil?
            self._duration = Storage.new(data: [], total: 0) if _duration.nil?
            parent = _duration.data << (current = [key, []])
            _duration.data = current[1]
            duration_total = _duration.total.clone
            current[2] = _duration_clock
            interactor.call
          ensure
            current[3] = _duration_clock
            current[4] = current[3] - current[2] - (_duration.total - duration_total)
            _duration.data = parent
            _duration.total += current[4]
            _duration_print if initial_operation
          end

          def _duration_print
            data = _duration.data
            self._duration = nil
            return data.each { _duration_current.push(_1) } if _duration_current

            ::Interactor::Extended.configuration.on_duration&.call(BaseFormatter.value(data))
          end
        end
      end
    end

    module ClassMethods
      # Enables duration tracking for the next defined method (or all methods if `all` is true).
      # @param all [bool] When true, tracks every subsequently defined method.
      # @return [void]
      def duration(all = false) # rubocop:disable Style/OptionalBooleanParameter
        @__duration_all_methods = true if all
        @__duration_next_method = true
      end

      # Wraps any method defined after a `duration` call with duration tracking.
      # @param name [Symbol] The name of the method that was just added.
      # @return [void]
      def method_added(name)
        super
        return unless @__duration_next_method

        @__duration_next_method = false
        original = instance_method(name)
        define_method(name) do |*args, **kwargs, &block|
          key = "#{self.class.name}##{name}"
          interactor = -> { original.bind_call(self, *args, **kwargs, &block) }
          _process_duration(interactor, key)
        end
        @__duration_next_method = true if @__duration_all_methods
      end
    end
  end
end
