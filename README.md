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

To install this gem onto your local machine, run `bundle exec rake install`.

This project is managed with [Reissue](https://github.com/SOFware/reissue). Releases are automated via the [shared release workflow](https://github.com/SOFware/reissue/blob/main/.github/workflows/SHARED_WORKFLOW_README.md). Trigger a release by running the "Release gem to RubyGems.org" workflow from the Actions tab.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SOFware/sof-mcm.
