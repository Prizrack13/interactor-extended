# Configuration

Global configuration can be set via `Interactor::Extended.configure`. This is typically done during application boot.

```ruby
Interactor::Extended.configure do |config|
  config.logger = Rails.logger
  config.type = :light # Options: :ctx, :light, :legacy, :all, :all_debug
  # config.type = [Interactor::Contextable]
  config.duration_format = :json # Options: :json, :string, :color_string
  config.on_duration = ->(duration) { print duration }
end
```

## Types
By default, including `Interactor::Operation` includes the full list of modules.
You can use a predefined set or create your own list.

```ruby
# Also you can include in a specific class another set
# include ::Interactor::Operation[:light]
# for example you need high performance class
# include ::Interactor::Operation[:base] # just base

TYPES = {
  base: [], # no extensions just Interactor or Flow 
  ctx: [::Interactor::Contextable], # improved context.
  light: [ # Core set with light context definition
    ::Interactor::Contextable,
    ::Interactor::LightContextDefinition,
    ::Interactor::Populate,
    ::Interactor::Organize
  ],
  legacy: [ # Base set with context validation and default + jobify
    ::Interactor::Contextable,
    ::Interactor::ContextDefinition,
    ::Interactor::Populate,
    ::Interactor::Organize,
    ::Interactor::Jobify
  ],
  all: [ # all modules
    ::Interactor::Contextable,
    ::Interactor::ContextDefinition,
    ::Interactor::Populate,
    ::Interactor::Organize,
    ::Interactor::Jobify,
    ::Interactor::Colorize,
    ::Interactor::Loggable
  ],
  all_debug: [ # all modules + modules good for debug
    ::Interactor::Contextable,
    ::Interactor::ContextDefinition,
    ::Interactor::Populate,
    ::Interactor::Organize,
    ::Interactor::Jobify,
    ::Interactor::Colorize,
    ::Interactor::Loggable,
    ::Interactor::Duration
  ]
}
```

[Back to README](../README.md)
