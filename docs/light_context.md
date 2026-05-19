# Interactor::LightContext

A lightweight, `BasicObject`-based context implementation. It minimizes overhead and is ideal for high-performance scenarios where standard context features are unnecessary. Unlike the standard context, it does not inherit from `Struct` or `OpenStruct`, but instead delegates attribute access to an underlying hash.

**Key Features:**
- Extremely low memory footprint
- Fast attribute access via `method_missing` delegation
- Compatible with standard interactor workflows

**Example:**
```ruby
class FastInteractor
  include Interactor::Operation

  def call
    context.value = 42
  end
end
```

**Note:** Because `LightContext` inherits from `BasicObject`, it lacks many standard Ruby object methods. It relies on `respond_to_missing?` and `method_missing` to provide context-like behavior. Use it when performance is critical and you don't need the full context API.
In most cases you should use context[:value] for better performance.

[Back to README](../README.md)
