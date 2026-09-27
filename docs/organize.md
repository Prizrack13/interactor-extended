# Interactor::Organize

Runs a list of interactors in sequence, sharing a single context.

## Entry forms

```ruby
class MyFlow
  include Interactor::Flow

  organize StepOne,                            # class
           { class: StepTwo, if: :enabled? },  # hash with condition
           :inline_step,                        # symbol — calls method on organizer
           step(StepThree, unless: :skip?),     # step helper
           thread(StepFour)                     # threaded

  def inline_step = StepOne.call!(context)
  def enabled?    = context[:enabled]
  def skip?       = context[:skip]
end
```

## Conditions

`:if` and `:unless` accept a Symbol (`send` on organizer) or a Proc (`instance_exec`):

```ruby
organize step(StepOne, if: :ready?),
         step(StepTwo, if: -> { context[:value].present? })
```

## Pair shorthand

A trailing hash without `:class` applies to the preceding entry:

```ruby
organize StepOne, { if: :ready? },
         StepTwo, { unless: :skip? }
```

## Threads

All threads are joined before `call` returns:

```ruby
organize thread(StepOne), thread(StepTwo), StepThree
```

## Symbol entries

A Symbol calls the named method on the organizer. Useful for inline logic or dynamic dispatch:

```ruby
organize :my_step, { if: :enabled? }

def my_step = StepOne.call!(context)
```

## Runtime override

```ruby
MyFlow.call!(organized: [StepOne])
```

## Inheritance

Subclasses inherit the parent's list unless they define their own.

[Back to README](../README.md)
