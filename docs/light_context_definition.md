# Interactor::LightContextDefinition

It similar to Interactor::ContextDefinition but it basically creates only read/write methods.

**Example:**
```ruby
class TypedInteractor
  include Interactor::Operation

  input  :id,     Integer, required: true
  input  :tags,   String,  array: true, default: []
  input  :active, :boolean
  output :result, Hash

  def call
    self.result = { id:, tags:, active: }
  end
end
```

[Back to Table of Contents](../interactors.md)
