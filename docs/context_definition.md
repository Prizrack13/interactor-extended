# Interactor::ContextDefinition

Declares typed inputs and outputs. Generates readers/writers, validates on every call, coerces values, and sets defaults.

## Example

```ruby
class TypedInteractor
  include Interactor::Operation

  input  :user_id,   Integer,  required: true
  input  :currency,  String,   inclusion: %w[EUR USD GBP]
  input  :status,    String,   exclusion: %w[banned]
  input  :email,     String,   format: /\A[^@]+@[^@]+\z/
  input  :amount,    String,   coerce: :to_i, numericality: { greater_than: 0 }
  input  :tags,      String,   array: true, default: []
  input  :active,    :boolean
  output :order,     Hash

  def call
    self.order = { user_id:, currency:, amount: }
  end
end
```

## Declaring attributes

```ruby
input  :name           # read-only input, available in call as `name`
output :result         # read-write output, setter generated as `self.result =`
input  :token, writer: true  # input with a setter (writable output semantics)
attribute :shared      # direction defaults to :output
```

## Type

Positional and keyword forms are equivalent:

```ruby
input :id, Integer
input :id, type: Integer
```

### Union type

An array of classes means "any of these types":

```ruby
input :id, [Integer, String]   # Integer or String
```

### Array type

`array: true` means every element must match the type:

```ruby
input :tags, String, array: true     # Array of Strings
input :ids,  Integer, array: true    # Array of Integers
input :nums, [Integer, Float], array: true  # Array of Integer or Float
```

### Boolean

```ruby
input :flag, :boolean
input :flag, Interactor::Boolean  # same
```

## Coercion

Applied before validation. Nil values are never coerced.

```ruby
input :count, coerce: :to_i                    # calls value.to_i
input :name,  coerce: ->(v) { v.strip }        # proc receives the raw value
input :score, coerce: ScoreParser              # calls ScoreParser.parse(value)
```

Coercion also runs in the output setter, so this works:

```ruby
output :total, coerce: :to_i
def call = self.total = params[:total]  # coerced to Integer
```

## Validations

All validators skip `nil` values unless `required: true` or `presence: true` is set.
Multiple errors are collected; on failure `context.errors` is a hash of `{key => [messages]}`.

### `required:`

```ruby
input :id, required: true   # fails if value is nil
```

### `presence:`

```ruby
input :name, presence: true  # fails if nil, empty string, blank string, or empty collection
```

### `absence:`

```ruby
input :deleted_at, absence: true  # fails if value is present (non-blank)
```

### `inclusion:`

```ruby
input :currency, inclusion: %w[EUR USD GBP]
input :status,   inclusion: { in: %w[active inactive], message: 'invalid status' }
```

### `exclusion:`

```ruby
input :role, exclusion: %w[admin superadmin]
```

### `format:`

```ruby
input :slug,  format: /\A[a-z0-9-]+\z/              # shorthand with:
input :code,  format: { with: /\A\d{4}\z/ }
input :notes, format: { without: /[<>]/ }
input :ref,   format: { with: /\A[A-Z]+\z/, message: 'must be uppercase letters' }
```

### `length:`

```ruby
input :pin,  length: { is: 4 }
input :bio,  length: { minimum: 10, maximum: 500 }
input :bio,  length: { in: 10..500 }              # same as above
input :name, length: { minimum: 2 }
```

Works on any value that responds to `#length` (strings, arrays).

### `numericality:`

```ruby
input :age,   numericality: true                            # any number or numeric string
input :score, numericality: { greater_than: 0 }
input :qty,   numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 99 }
input :rank,  numericality: { only_integer: true }
input :page,  numericality: { odd: true }
input :seats, numericality: { even: true }
input :n,     numericality: { equal_to: 42 }
input :code,  numericality: { other_than: 0 }
```

Accepts `Integer`, `Float`, and numeric strings. Comparison keys: `equal_to`, `other_than`, `greater_than`, `greater_than_or_equal_to`, `less_than`, `less_than_or_equal_to`.

### `validate:`

Symbol — calls a method on the interactor instance:

```ruby
input :email, validate: :valid_email?

private

def valid_email? = email.include?('@')
```

Proc — receives the value; `self` is the interactor instance:

```ruby
input :age,    validate: ->(v) { v >= 18 }
input :amount, validate: -> { context[:amount] > context[:minimum] }
```

Return a `String` to use it directly as the error message:

```ruby
input :code, validate: ->(v) { 'must be 3 chars' unless v.length == 3 }
```

### `validations:` — multiple validators per attribute

Each entry can be a hash with one validator key, a bare validator class, or a `{ with: ValidatorClass }` form. An optional `message:` overrides that entry's error string.

```ruby
input :currency, validations: [
  { type: String,            message: 'must be a string' },
  { inclusion: %w[EUR USD],  message: 'must be EUR or USD' },
  { validate: :active_currency? }
]

input :token, validations: [
  MyCustomValidator,                        # class with #validate(value, interactor)
  { with: MyCustomValidator, message: '…' } # same with message override
]
```

All validators run; `result.errors[:key]` may contain multiple strings.

## Defaults

Static values are deep-duped so each call gets its own copy:

```ruby
input :tags,    default: []
input :options, default: {}
input :locale,  default: 'en'
```

Proc defaults receive `(interactor, context)` or `(interactor)` or `()` depending on arity:

```ruby
input :ref, default: -> { SecureRandom.uuid }
input :at,  default: ->(_, ctx) { ctx[:requested_at] || Time.now }
```

## Options reference

| Option | Default | Description |
|---|---|---|
| `type` | — | Expected class or array of classes (positional or keyword) |
| `array` | `false` | Every element must match the type |
| `coerce` | — | `:method`, `proc`, or class with `.parse` — applied before validation |
| `required` | — | Fails if value is `nil` |
| `presence` | — | Fails if value is blank (nil, empty string/collection) |
| `absence` | — | Fails if value is present |
| `inclusion` | — | Value must be in the list |
| `exclusion` | — | Value must not be in the list |
| `format` | — | Regex or `{ with:, without: }` |
| `length` | — | `{ is:, minimum:, maximum:, in: }` |
| `numericality` | — | `true` or constraint hash |
| `validate` | — | Symbol or Proc; `false`/String return → invalid |
| `validations` | — | Array of validator entries, all run |
| `default` | — | Static value (deep-duped) or Proc |
| `writer` | `false` | `input` only — also generates a setter |

## Custom validators

Subclass `Interactor::Validations::Base`. The class name is used as the registry key (snake_case). Override `register_as` to use a different key.

```ruby
class StrongPassword < Interactor::Validations::Base
  def validate(value, _interactor)
    return nil if value.nil?
    return 'must be at least 12 characters' if value.length < 12
    return 'must include a digit' unless value.match?(/\d/)
    nil
  end
end

# Used automatically:
input :password, strong_password: true
```

## Inheritance

Subclasses inherit all parent attributes.

[Back to README](../README.md)
