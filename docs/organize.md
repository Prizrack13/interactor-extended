# Interactor::Organize

It adds useful methods.
With organize key you can run only specific interactors.
Also, you can run interactos in parallel way using thread method.

**Example:**
```ruby
class ParallelFlow
  include Interactor::Flow

  organize(
    thread(SimpleInteractor),
    thread(SimpleSecondInteractor)
  )
end
ParallelFlow.call!(organize: [SimpleInteractor])
```

[Back to README](../README.md)
