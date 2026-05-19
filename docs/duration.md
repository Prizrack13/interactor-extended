# Interactor::Duration

Tracks execution time for each interactor in a flow. Supports multiple formatters for output customization.

**Formatters:**
- :json => `JsonFormatter`: Returns JSON-compatible array of hashes.
- :string => `StringFormatter`: Returns a plain text table.
- :color_string => `ColorStringFormatter`: Returns an ANSI-colored string for terminal output.

**Configuration:**
```ruby
Interactor::Extended.configure do
  _1.duration_format = :color_string
  _1.on_duration = ->(duration) { puts duration }
end
```

Also you can do benchmark of methods by calling duration before method or duration(true) to track all methods in class.
```
class Operation
  include Interactor::Operation
  
  duration # or duration(true)
  def call
    ...
  end
end
```

**Example Output:**
```
- Flow   count: 1   time: 53040.76   own: 27358.89
- Operation count: 2771 time: 9.27     own: 9.27
- Operation#call count: 2771 time: 9.27     own: 9.27
```

[Back to README](../README.md)
