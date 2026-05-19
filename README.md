# Interactor::Extended

[![Quality Checks](https://github.com/Prizrack13/interactor-extended/actions/workflows/pull-requests.yml/badge.svg)](https://github.com/Prizrack13/interactor-extended/actions/workflows/pull-requests.yml)

A powerful extension for the `interactor` gem, providing a set of modules. Lightweight context, self-documented input/output attributes, logging, job integration, duration tracking debug, and more.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'interactor-extended'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install interactor-extended
```

## Usage

```ruby
class MyInteractor
  include Interactor::Operation

  input :id, Integer, require: true
  output :user, User

  def call
    logger.info "Processing user: #{id}"
    self.user = User.find(id)
  rescue ActiveRecord::RecordNotFound
    context.fail!(error: 'User not found')
  end
end

result = MyInteractor.call(id: 1)
result.success? # => true
result.user     # => #<User ...>
```

## Documentation

### Core Modules
- [Operation](docs/operation.md)
- [Flow](docs/flow.md)
- [Organize](docs/organize.md)
- [LightContext](docs/light_context.md)
- [ContextDefinition & Contextable](docs/context_definition.md)

### Extensions & Utilities
- [Duration](docs/duration.md)
- [Loggable](docs/loggable.md)
- [Jobify](docs/jobify.md)
- [Populate](docs/populate.md)
- [Extended](docs/extended.md)
- [Colorize](docs/colorize.md)

### Additional Guides
- [Configuration](docs/configuration.md)
- [Best Practices](docs/best_practices.md)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/prizrack13/interactor-extended. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/prizrack13/interactor-extended/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Interactor::Extended project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/prizrack13/interactor-extended/blob/master/CODE_OF_CONDUCT.md).
