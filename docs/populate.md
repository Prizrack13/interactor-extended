# Interactor::Populate

Enables selective context passing between interactors. Useful when you want to copy/update specific keys in the parent context.
By default, it copies all keys started with underscore.

**Example:**
```ruby
class AnotherInteractor
  include Interactor::Operation

  input :a
  output :c
  def call
    self.c = a * 2
  end
end

class SimpleInteractor
  include Interactor::Operation

  input :a
  input :b
  def call
    AnotherInteractor.call!(context) # it will populate all context
    p b
    AnotherInteractor.call!({ a: a * 2 }, context, :c)
    p context.c
    # or 
    # AnotherInteractor.call!(a: a * 2, context: context, context_keys: %i[c])
  end
end
```

[Back to README](../README.md)
