# Interactor::Operation

The foundational module for creating interactors. It provides context management, success/failure handling, and integrates seamlessly with other extensions.

**Example:**
```ruby
class SimpleInteractor
  include Interactor::Operation

  def call
    # Access context values
    p context.a
    
    # Fail the interactor if validation fails
    context.fail!(error: 'Invalid input') unless context.a.is_a?(Integer)
    
    # Set output values
    context.data = context.a * 2
  end
end

# Execution
result = SimpleInteractor.call(a: 1)
result.success? # => true
result.data     # => 2

result = SimpleInteractor.call(a: '')
result.success? # => false

# Raises Interactor::Failure if not successful
SimpleInteractor.call!(a: '') 
```

[Back to README](../README.md)
