# Interactor::ContextDefinition

Provides type-safe input/output definitions with validation, requirement checks, and array handling.
It creates read/write methods and avoid OpenStruct performance issues. Since it is use context[].

**Example:**
```ruby
class TypedInteractor
  include Interactor::Operation

  input :a, Integer
  input :b, String, require: true
  output :c, [Integer, String], array: true
  def call
    # Validation automatically checks types and requirements
    self.c = [a, b]
  end
end
```

[Back to README](../README.md)
