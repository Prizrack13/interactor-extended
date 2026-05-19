# Interactor::Colorize

Provides ANSI color codes for terminal output. Used internally by `ColorStringFormatter` but available for custom logging.

**Example:**
```ruby
require 'interactor/colorize'

puts Interactor::Colorize.colorize('Success', :green)
puts Interactor::Colorize.colorize('Warning', :yellow)
puts Interactor::Colorize.colorize('Error', :red)

class SimpleInteractor
  include Interactor::Operation

  def call
    puts colorize('Success', :green)
  end
end
```

[Back to README](../README.md)
