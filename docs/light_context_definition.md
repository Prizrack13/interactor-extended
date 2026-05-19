# Interactor::LightContextDefinition

It similar to Interactor::ContextDefinition but it basically creates only read/write methods.

**Example:**
```ruby
class TypedInteractor
  include Interactor::Operation

  input :a, Integer
  input :b, String, require: true
  output :c, [Integer, String], array: true
  def call
    self.c = [a, b]
  end
end
```

[Back to Table of Contents](../interactors.md)
