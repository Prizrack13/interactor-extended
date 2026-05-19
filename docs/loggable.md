# Interactor::Loggable

Adds a logger instance to the interactor context. Automatically configures log levels and formatting.

**Example:**
```ruby
class LoggedInteractor
  include Interactor::Operation

  def call
    logger.debug "Processing context: #{context.inspect}"
    logger.info "Completed successfully"
  end
end
```

[Back to README](../README.md)
