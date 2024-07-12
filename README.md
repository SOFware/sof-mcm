# SOF::MCM

SOF::MCM allows you to access the MCM API.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add sof-mcm

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install sof-mcm

## Usage

Assign users to applications from the module

```ruby
require "sof-mcm"
SOF::MCM.assign("SOME-ID", "application name")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SOFware/sof-mcm.
