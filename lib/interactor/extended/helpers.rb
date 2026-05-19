# frozen_string_literal: true

module Interactor
  module Extended
    # Provides helper methods for the Extended gem.
    module Helpers
      # Deeply duplicates an object.
      # @param obj [untyped] The object to duplicate.
      # @return [untyped]
      def deep_dup(obj)
        case obj
        when Hash
          obj.to_h { |k, v| [deep_dup(k), deep_dup(v)] }
        when Array
          obj.map { deep_dup(_1) }
        when NilClass, FalseClass, TrueClass, Symbol, Numeric
          obj
        else
          obj.dup
        end
      end

      # Deeply transforms keys of an object.
      # @param object [untyped] The object to transform.
      # @yield [Symbol] The key to transform.
      # @return [untyped]
      def deep_transform_keys(object, &block)
        case object
        when Hash
          object.each_with_object({}) do |(key, value), result|
            result[yield(key)] = deep_transform_keys(value, &block)
          end
        when Array
          object.map { deep_transform_keys(_1, &block) }
        else
          object
        end
      end

      # Safely constantizes a string.
      # @param camel_cased_word [String] The string to constantize.
      # @return [untyped]
      def safe_constantize(camel_cased_word)
        Object.const_get(camel_cased_word)
      rescue NameError => e
        raise if e.name && !(camel_cased_word.to_s.split('::').include?(e.name.to_s) ||
          e.name.to_s == camel_cased_word.to_s)
      rescue LoadError => e
        message = e.respond_to?(:original_message) ? e.original_message : e.message
        raise unless /Unable to autoload constant #{const_regexp(camel_cased_word)}/.match?(message)
      end
    end
  end
end
