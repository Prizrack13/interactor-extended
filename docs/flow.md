# Interactor::Flow

Allows chaining multiple interactors sequentially. The context is passed from one interactor to the next, enabling complex workflows.

**Example:**
```ruby
class SimpleSecondInteractor
  include Interactor::Operation

  def call
    p context.data # Receives data from SimpleInteractor
  end
end

class SimpleFlow
  include Interactor::Flow
  
  organize SimpleInteractor, SimpleSecondInteractor
end

# Runs both interactors in sequence
SimpleFlow.call!(a: 2)
```

[Back to README](../README.md)
